# Source Accounts Terraform - Deploys IAM roles in all source accounts

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ─── Production Accounts ──────────────────────────────────────────────────────

module "core_prod_workload" {
  source                   = "../modules/iam-roles"
  account_id               = "986788162487"
  account_name             = "core-prod-workload"
  eks_cluster_oidc_issuer  = var.oidc_issuers["core-prod-workload"]
  providers = { aws = aws.core_prod_workload }
}

module "counselling_prod" {
  source                   = "../modules/iam-roles"
  account_id               = "376129876930"
  account_name             = "counselling-prod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["counselling-prod"]
  providers = { aws = aws.counselling_prod }
}

module "paymentpro_prod" {
  source                   = "../modules/iam-roles"
  account_id               = "503561424407"
  account_name             = "paymentpro-prod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["paymentpro-prod"]
  providers = { aws = aws.paymentpro_prod }
}

module "ethinos_prod" {
  source                   = "../modules/iam-roles"
  account_id               = "484021612095"
  account_name             = "ethinos-prod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["ethinos-prod"]
  providers = { aws = aws.ethinos_prod }
}

module "grooming_lms_prod" {
  source                   = "../modules/iam-roles"
  account_id               = "573811483933"
  account_name             = "grooming-lms-prod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["grooming-lms-prod"]
  providers = { aws = aws.grooming_lms_prod }
}

module "tomms" {
  source                   = "../modules/iam-roles"
  account_id               = "039138653430"
  account_name             = "tomms"
  eks_cluster_oidc_issuer  = var.oidc_issuers["tomms"]
  providers = { aws = aws.tomms }
}

# ─── Non-Production Accounts ──────────────────────────────────────────────────

module "core_nonprod_workload" {
  source                   = "../modules/iam-roles"
  account_id               = "228227093546"
  account_name             = "core-nonprod-workload"
  eks_cluster_oidc_issuer  = var.oidc_issuers["core-nonprod-workload"]
  providers = { aws = aws.core_nonprod_workload }
}

module "counselling_nonprod" {
  source                   = "../modules/iam-roles"
  account_id               = "992382651259"
  account_name             = "counselling-nonprod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["counselling-nonprod"]
  providers = { aws = aws.counselling_nonprod }
}

module "paymentpro_nonprod" {
  source                   = "../modules/iam-roles"
  account_id               = "337909775485"
  account_name             = "paymentpro-nonprod"
  eks_cluster_oidc_issuer  = var.oidc_issuers["paymentpro-nonprod"]
  providers = { aws = aws.paymentpro_nonprod }
}
