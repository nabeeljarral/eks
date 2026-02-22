resource "aws_eks_cluster" "eks" {
  name     = "${var.project}-${var.environment}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}