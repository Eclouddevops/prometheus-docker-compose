# Reusable module: creates AMP source IAM role in any account
# Usage: call this module from source-accounts/main.tf per account

variable "account_id" {
  description = "Source account ID"
  type        = string
}

variable "account_name" {
  description = "Human-readable account name"
  type        = string
}

variable "eks_cluster_oidc_issuer" {
  description = "EKS cluster OIDC issuer URL (without https://)"
  type        = string
  default     = ""
}

variable "central_account_role_arn" {
  description = "ARN of cross-account role in central monitoring account"
  type        = string
  default     = "arn:aws:iam::426336593251:role/AMP-CrossAccount-RemoteWrite"
}

variable "namespace" {
  description = "Kubernetes namespace where Prometheus runs"
  type        = string
  default     = "monitoring"
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "amp-sa"
}

# IRSA trust policy (for EKS workloads)
data "aws_iam_policy_document" "trust" {
  dynamic "statement" {
    for_each = var.eks_cluster_oidc_issuer != "" ? [1] : []
    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_cluster_oidc_issuer}"]
      }
      condition {
        test     = "StringEquals"
        variable = "${var.eks_cluster_oidc_issuer}:sub"
        values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
      }
      condition {
        test     = "StringEquals"
        variable = "${var.eks_cluster_oidc_issuer}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }

  # Fallback for EC2 / non-EKS
  dynamic "statement" {
    for_each = var.eks_cluster_oidc_issuer == "" ? [1] : []
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "amp_remote_write" {
  name               = "AMP-RemoteWrite-Role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags = {
    ManagedBy   = "terraform"
    AccountName = var.account_name
    Purpose     = "AMP cross-account metrics shipping"
  }
}

resource "aws_iam_role_policy" "assume_central_role" {
  name = "AMP-AssumeRole-Policy"
  role = aws_iam_role.amp_remote_write.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AssumeCentralAMPRole"
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = var.central_account_role_arn
    }]
  })
}

output "role_arn" {
  value = aws_iam_role.amp_remote_write.arn
}
