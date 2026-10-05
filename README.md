# 🔭 AWS AMP Central Monitoring

Centralized **Amazon Managed Prometheus (AMP)** configuration for **49 AWS accounts** across multiple environments and teams.

---

## 📁 Repository Structure

```
aws-amp-central-monitoring/
├── workspaces/              # AMP workspace definitions
├── iam/
│   ├── central-account/     # IAM roles in monitoring hub account
│   └── source-accounts/     # IAM roles to deploy per source account
├── prometheus/
│   ├── configs/             # Prometheus scrape configs per account
│   └── rules/
│       ├── prod/            # Alerting rules for production
│       ├── nonprod/         # Alerting rules for non-prod
│       └── common/          # Shared rules across all envs
├── kubernetes/
│   ├── helm/                # Helm values per account/cluster
│   └── manifests/           # Raw Kubernetes manifests
├── grafana/
│   ├── dashboards/          # Dashboard JSON files
│   └── datasources/         # Datasource configs
├── terraform/
│   ├── central-account/     # Terraform for hub account setup
│   ├── source-accounts/     # Terraform for source account roles
│   └── modules/             # Reusable Terraform modules
├── scripts/                 # Automation scripts
└── docs/                    # Architecture & runbooks
```

---

## 🏗️ Architecture

```
Central Account: Core_Account_SharedServices (426336593251)
├── AMP Workspace: central-nonprod-monitoring  (us-east-1)
└── AMP Workspace: central-prod-monitoring     (ap-south-1)
        ▲                        ▲
        │                        │
 NonProd Accounts          Prod Accounts
 (push metrics)            (push metrics)
```

---

## 🗂️ Account Groups

| Group | Environment | Key Accounts |
|-------|-------------|--------------|
| Core Prod | Production | core-prod, core-prod-workload, core-prod-security |
| Core NonProd | Non-Production | core-nonprod-workload, core-nonprod-security |
| Counselling | Both | counselling-prod, counselling-nonprod |
| PaymentPro | Both | PaymentPro-Prod, PaymentPro-NonProd |
| Grooming School | Production | Grooming-School-Lms-Prod |
| Ethinos | Production | ethinos-prod |
| TimesGroup | Shared | TimesGroup-TEEL |
| Sandbox | Dev | devika-sandbox, AI_Hackathon |

---

## 🚀 Quick Start

### 1. Deploy Central Account Resources (Terraform)
```bash
cd terraform/central-account
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply
```

### 2. Deploy Source Account IAM Roles
```bash
cd terraform/source-accounts
# Edit accounts.auto.tfvars with account IDs
terraform init
terraform plan
terraform apply
```

### 3. Deploy Prometheus Agent on EKS
```bash
# For a specific account cluster
cd kubernetes/helm
helm upgrade --install prometheus-amp . \
  -f values/core-prod-workload.yaml \
  --namespace monitoring --create-namespace
```

---

## 📋 Account Reference

See [docs/accounts.md](docs/accounts.md) for full account list with IDs, regions, and teams.

---

## 🔐 Security

- All metric shipping uses **AWS SigV4 signing**
- Cross-account access via **IAM Role Assumption** (no long-lived credentials)
- EKS workloads use **IRSA** (IAM Roles for Service Accounts)
- Sensitive values stored in **AWS Secrets Manager** / Parameter Store

---

## 📞 Support

| Team | Contact |
|------|---------|
| DevOps | DevOps Team |
| Platform | Core Platform Team |
