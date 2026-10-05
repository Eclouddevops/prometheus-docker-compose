#!/bin/bash
# ============================================================
# Deploy Prometheus + SigV4 Proxy to an EKS cluster
# Usage: ./deploy-prometheus.sh <account-profile> <kubeconfig>
# ============================================================

set -euo pipefail

ACCOUNT_PROFILE="${1:-}"
KUBECONFIG_PATH="${2:-~/.kube/config}"
NAMESPACE="monitoring"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()   { echo -e "${GREEN}[INFO]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[ -z "$ACCOUNT_PROFILE" ] && error "Usage: $0 <account-profile> [kubeconfig-path]"

# Helm values file lookup
VALUES_FILE="./kubernetes/helm/values/${ACCOUNT_PROFILE}.yaml"
[ ! -f "$VALUES_FILE" ] && error "Values file not found: $VALUES_FILE"

log "Deploying Prometheus AMP to cluster for: $ACCOUNT_PROFILE"

# Create namespace
kubectl --kubeconfig="$KUBECONFIG_PATH" create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create service account (IRSA)
ROLE_ARN=$(grep "eks.amazonaws.com/role-arn" "$VALUES_FILE" | awk '{print $2}' | tr -d '"')
kubectl --kubeconfig="$KUBECONFIG_PATH" create serviceaccount amp-sa \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | \
  kubectl annotate --local -f - \
    "eks.amazonaws.com/role-arn=${ROLE_ARN}" \
    --overwrite -o yaml | \
  kubectl apply -f -

# Copy rules to configmap
kubectl --kubeconfig="$KUBECONFIG_PATH" create configmap prometheus-rules \
  --from-file=./prometheus/rules/common/ \
  --from-file=./prometheus/rules/prod/ \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy via Helm
helm upgrade --install prometheus-amp ./kubernetes/helm \
  -f "$VALUES_FILE" \
  --namespace "$NAMESPACE" \
  --kubeconfig="$KUBECONFIG_PATH" \
  --wait \
  --timeout=5m

log "✅ Prometheus AMP deployed successfully to $ACCOUNT_PROFILE"
log "Verify: kubectl --kubeconfig=$KUBECONFIG_PATH get pods -n $NAMESPACE"
