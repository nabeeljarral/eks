resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS Control Plane"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow worker nodes to communicate with cluster"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project}-${var.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow cluster communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # < FIX
  }

  # Allow nodes to communicate with each other
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # < FIX
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}