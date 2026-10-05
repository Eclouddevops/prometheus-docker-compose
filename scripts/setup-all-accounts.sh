#!/bin/bash
# ============================================================
# AMP Setup Script - All Source Accounts
# Deploys IAM role in every source account automatically
# ============================================================

set -euo pipefail

CENTRAL_ACCOUNT="426336593251"
CENTRAL_PROFILE="Core_Account_SharedServices"
CENTRAL_ROLE_NAME="AMP-CrossAccount-RemoteWrite"
SOURCE_ROLE_NAME="AMP-RemoteWrite-Role"

# Color output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()   { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ─── All Source Accounts ─────────────────────────────────────
declare -A ACCOUNTS=(
  # Profile=AccountID
  ["core-prod"]="840066156479"
  ["core-prod-security"]="814167067247"
  ["core-prod-storage"]="194374732776"
  ["core-prod-workload"]="986788162487"
  ["counselling-prod"]="376129876930"
  ["ethinos-prod"]="484021612095"
  ["PaymentPro-Prod"]="503561424407"
  ["Grooming-School-Lms-Prod"]="573811483933"
  ["TOMMS"]="039138653430"
  ["core-nonprod-audit"]="596338505229"
  ["core-nonprod-networking"]="579286803788"
  ["core-nonprod-security"]="081027471069"
  ["core-nonprod-storage"]="509235756237"
  ["core-nonprod-workload"]="228227093546"
  ["counselling-nonprod"]="992382651259"
  ["PaymentPro-NonProd"]="337909775485"
  ["NonProd"]="243244970719"
  ["Grooming-School-LMS-Moodle"]="025688828853"
  ["AI_Hackathon"]="248189944202"
  ["devika-sandbox"]="196252597537"
  ["devops-team"]="713678752742"
  ["finbot"]="343268907886"
  ["swap-devops"]="316929918327"
  ["Core_Account_Network"]="441508417985"
  ["Core_Complience"]="560885581232"
  ["Core_Governance"]="968311652915"
  ["BOT_Process"]="903001346340"
  ["TEELSSA"]="652892608280"
  ["TimesGroup-TEEL"]="226563001214"
  ["executive-education"]="734352162710"
  ["ethinos"]="884614646509"
)

# ─── Step 1: Get Central Account Role ARN ─────────────────────
CENTRAL_ROLE_ARN="arn:aws:iam::${CENTRAL_ACCOUNT}:role/${CENTRAL_ROLE_NAME}"
log "Central Role ARN: ${CENTRAL_ROLE_ARN}"

# ─── Step 2: Create IAM Role in Each Source Account ───────────
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

for PROFILE in "${!ACCOUNTS[@]}"; do
  ACCOUNT_ID="${ACCOUNTS[$PROFILE]}"
  
  echo ""
  log "Processing: $PROFILE ($ACCOUNT_ID)"
  
  # Check if profile exists
  if ! aws configure list-profiles 2>/dev/null | grep -q "^${PROFILE}$"; then
    warn "Profile '$PROFILE' not found, skipping..."
    ((SKIP_COUNT++))
    continue
  fi

  # Check if role already exists
  if aws iam get-role --role-name "$SOURCE_ROLE_NAME" --profile "$PROFILE" &>/dev/null; then
    warn "Role $SOURCE_ROLE_NAME already exists in $PROFILE, skipping..."
    ((SKIP_COUNT++))
    continue
  fi

  # Create trust policy (EC2 fallback, update for EKS IRSA per cluster)
  TRUST_POLICY='{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

  # Create the IAM role
  if aws iam create-role \
      --role-name "$SOURCE_ROLE_NAME" \
      --assume-role-policy-document "$TRUST_POLICY" \
      --description "Allows assuming central AMP cross-account role" \
      --profile "$PROFILE" \
      --output text \
      --query 'Role.RoleId' &>/dev/null; then

    # Attach assume role policy
    POLICY="{
      \"Version\": \"2012-10-17\",
      \"Statement\": [{
        \"Sid\": \"AssumeCentralAMPRole\",
        \"Effect\": \"Allow\",
        \"Action\": \"sts:AssumeRole\",
        \"Resource\": \"${CENTRAL_ROLE_ARN}\"
      }]
    }"

    aws iam put-role-policy \
      --role-name "$SOURCE_ROLE_NAME" \
      --policy-name "AMP-AssumeRole-Policy" \
      --policy-document "$POLICY" \
      --profile "$PROFILE" &>/dev/null

    log "✅ Created role in $PROFILE ($ACCOUNT_ID)"
    ((SUCCESS_COUNT++))
  else
    error "❌ Failed to create role in $PROFILE ($ACCOUNT_ID)"
    ((FAIL_COUNT++))
  fi
done

# ─── Summary ──────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "           SETUP SUMMARY"
echo "════════════════════════════════════════"
log   "✅ Success: $SUCCESS_COUNT accounts"
warn  "⏭️  Skipped: $SKIP_COUNT accounts"
if [ $FAIL_COUNT -gt 0 ]; then
  error "❌ Failed:  $FAIL_COUNT accounts"
fi
echo "════════════════════════════════════════"
