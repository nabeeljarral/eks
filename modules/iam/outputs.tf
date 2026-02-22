
output "bastion_instance_profile" {
  value = aws_iam_instance_profile.bastion_profile.name
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}