resource "aws_eks_cluster" "sindhbank" {
  name     = "${var.project}-${var.environment}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  version = "1.30"

  tags = {
    Name    = "${var.project}-${var.environment}-eks"
    Module  = "eks"
    Owner   = "SindhBank-InfraTeam"
  }
}


