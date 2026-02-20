output "eks_cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_nodegroup_role_arn" {
  description = "EKS Nodegroup IAM Role ARN"
  value       = aws_iam_role.nodegroup_role.arn
}

output "bastion_role_arn" {
  description = "Bastion SSM/Telemetry IAM Role ARN"
  value       = aws_iam_role.bastion_ssm_role.arn
}

output "bastion_instance_profile" {
  description = "Instance Profile for Bastion Host"
  value       = aws_iam_instance_profile.bastion_profile.name
}

output "eks_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "eks_oidc_provider" {
  value = aws_iam_openid_connect_provider.eks.url
}

