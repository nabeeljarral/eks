resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.sindhbank.name
  node_group_name = "${var.project}-${var.environment}-private-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    Module      = "eks-nodegroup"
  }
}
