# Central Account Terraform - Creates AMP Workspaces + Cross-Account IAM Role
# Deploy in: Core_Account_SharedServices (426336593251)

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-426336593251"
    key    = "amp/central-account/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "Core_Account_SharedServices"
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
  profile = "Core_Account_SharedServices"
}

# ─── AMP Workspaces ───────────────────────────────────────────────────────────

resource "aws_prometheus_workspace" "nonprod" {
  provider = aws.us_east_1
  alias    = "central-nonprod-monitoring"
  tags = {
    Environment = "nonprod"
    ManagedBy   = "terraform"
    Team        = "devops"
  }
}

resource "aws_prometheus_workspace" "prod" {
  provider = aws.ap_south_1
  alias    = "central-prod-monitoring"
  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Team        = "devops"
  }
}

# ─── Cross-Account IAM Role ───────────────────────────────────────────────────

resource "aws_iam_role" "amp_cross_account" {
  name               = "AMP-CrossAccount-RemoteWrite"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags = {
    ManagedBy = "terraform"
    Purpose   = "AMP cross-account metrics ingestion"
  }
}

data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AllowSourceAccountsToAssume"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [for account_id in var.source_account_ids :
        "arn:aws:iam::${account_id}:root"
      ]
    }
  }
}

resource "aws_iam_role_policy" "amp_permissions" {
  name = "AMP-RemoteWrite-Policy"
  role = aws_iam_role.amp_cross_account.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AMPRemoteWrite"
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata",
          "aps:QueryMetrics"
        ]
        Resource = [
          aws_prometheus_workspace.nonprod.arn,
          aws_prometheus_workspace.prod.arn
        ]
      }
    ]
  })
}

# ─── SSM Parameters (for source accounts to discover workspace IDs) ───────────

resource "aws_ssm_parameter" "nonprod_workspace_id" {
  provider = aws.us_east_1
  name     = "/amp/workspaces/nonprod/workspace-id"
  type     = "String"
  value    = aws_prometheus_workspace.nonprod.id
}

resource "aws_ssm_parameter" "prod_workspace_id" {
  provider = aws.ap_south_1
  name     = "/amp/workspaces/prod/workspace-id"
  type     = "String"
  value    = aws_prometheus_workspace.prod.id
}
