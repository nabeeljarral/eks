#############################################
# SECURITY GROUPS FOR EKS CLUSTER & NODES
#############################################

# -------------------------------
# 🟦 EKS Cluster Security Group
# -------------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS Control Plane (API Server)"
  vpc_id      = var.vpc_id

  # No inbound rules here — AWS manages access to the control plane.
  # We only allow access from worker nodes.
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${var.environment}-eks-cluster-sg"
    }
  )
}

# Allow worker nodes to communicate with the control plane
resource "aws_security_group_rule" "cluster_api_inbound_from_nodes" {
  type                     = "ingress"
  description              = "Allow worker nodes to talk to EKS API"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
}

# -------------------------------
# 🟩 EKS Nodegroup Security Group
# -------------------------------
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.project}-${var.environment}-eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${var.environment}-eks-node-sg"
    }
  )
}

# Allow worker nodes to communicate internally
resource "aws_security_group_rule" "nodes_inbound_nodes" {
  type              = "ingress"
  description       = "Allow node-to-node traffic"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_blocks       = ["10.0.0.0/16"] # adjust based on your VPC CIDR
}

# Allow workers to receive traffic from cluster SG (optional)
resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  description              = "Allow cluster to talk to nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# Allow outbound internet (through NAT)
resource "aws_security_group_rule" "nodes_outbound" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}