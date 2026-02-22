############################################################
# LOCALS
############################################################
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

# ############################################################
# # 🟦 EKS CLUSTER IAM ROLE
# ############################################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ---------------- Node Role ------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

############################################################
# 🟥 BASTION IAM ROLE (SSM + EKS ACCESS)
############################################################
data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bastion_ssm_role" {
  name               = "${local.name_prefix}-bastion-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "bastion_eks_access" {
  name        = "${local.name_prefix}-bastion-eks-access"
  description = "Allow Bastion host to query EKS cluster details"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_attach_eks" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.bastion_eks_access.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.name_prefix}-bastion-profile"
  role = aws_iam_role.bastion_ssm_role.name
  tags = local.common_tags
}