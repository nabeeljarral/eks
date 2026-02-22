resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.project}-${var.environment}-private-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = null   # private nodes, no SSH
  }

  tags = {
    Name        = "${var.project}-${var.environment}-private-nodes"
    Project     = var.project
    Environment = var.environment
  }

  depends_on = [
    aws_eks_cluster.eks
  ]
}
