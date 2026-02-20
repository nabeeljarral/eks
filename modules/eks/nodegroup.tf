resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.sindhbank.name
  node_group_name = "${var.project}-${var.environment}-private-ng"
  node_role_arn   = var.node_role_arn

  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 6
    min_size     = 1
  }

  instance_types = ["t3.micro"]

  capacity_type = "ON_DEMAND"

  tags = {
    Name   = "${var.project}-${var.environment}-private-ng"
    Module = "eks-nodegroup"
  }
}