output "cluster_name" {
  value = aws_eks_cluster.sindhbank.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.sindhbank.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.sindhbank.certificate_authority[0].data
}

output "nodegroup_name" {
  value = aws_eks_node_group.private_nodes.node_group_name
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.sindhbank.identity[0].oidc[0].issuer
}


