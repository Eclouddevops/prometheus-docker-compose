variable "oidc_issuers" {
  description = "Map of account name to EKS OIDC issuer (without https://)"
  type        = map(string)
  default     = {
    "core-prod-workload"    = ""  # Replace: oidc.eks.ap-south-1.amazonaws.com/id/XXXXX
    "counselling-prod"      = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "paymentpro-prod"       = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "ethinos-prod"          = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "grooming-lms-prod"     = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "tomms"                 = ""  # Replace: oidc.eks.ap-south-1.amazonaws.com/id/XXXXX
    "core-nonprod-workload" = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "counselling-nonprod"   = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
    "paymentpro-nonprod"    = ""  # Replace: oidc.eks.us-east-1.amazonaws.com/id/XXXXX
  }
}
