output "nonprod_workspace_id" {
  description = "AMP NonProd Workspace ID"
  value       = aws_prometheus_workspace.nonprod.id
}

output "nonprod_workspace_endpoint" {
  description = "AMP NonProd Remote Write Endpoint"
  value       = "${aws_prometheus_workspace.nonprod.prometheus_endpoint}api/v1/remote_write"
}

output "prod_workspace_id" {
  description = "AMP Prod Workspace ID"
  value       = aws_prometheus_workspace.prod.id
}

output "prod_workspace_endpoint" {
  description = "AMP Prod Remote Write Endpoint"
  value       = "${aws_prometheus_workspace.prod.prometheus_endpoint}api/v1/remote_write"
}

output "cross_account_role_arn" {
  description = "Cross-account IAM role ARN - use in all source accounts"
  value       = aws_iam_role.amp_cross_account.arn
}
