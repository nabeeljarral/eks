
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

############################################################
# 🟦 EKS CLUSTER IAM ROLE
############################################################

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${local.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attach" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################################################
# 🟩 EKS NODEGROUP IAM ROLE
############################################################

resource "aws_iam_role" "nodegroup_role" {
  name               = "${local.name_prefix}-eks-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.nodegroup_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "nodegroup_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Worker Node Policies
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################################
# 🟥 BASTION IAM ROLE (SSM + EKS Access)
############################################################

### EC2 Assume Role
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

### Bastion Role
resource "aws_iam_role" "bastion_ssm_role" {
  name               = "${local.name_prefix}-bastion-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
  tags               = local.common_tags
}

### 🔵 SSM Core Permissions (Required for SSM Session Manager)
resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

### 🟢 Bastion EKS Access (needed for aws eks update-kubeconfig)
resource "aws_iam_policy" "bastion_eks_access" {
  name        = "${local.name_prefix}-bastion-eks-access"
  description = "Allow Bastion host to query EKS cluster details"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_attach_eks" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.bastion_eks_access.arn
}

### Instance Profile for Bastion
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.name_prefix}-bastion-profile"
  role = aws_iam_role.bastion_ssm_role.name
  tags = local.common_tags
}

############################################################
# 🟨 IRSA Role for ALB Controller
############################################################

resource "aws_iam_openid_connect_provider" "eks" {
  url             = var.oidc_provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10dfb"] # AWS public OIDC thumbprint
}

data "aws_iam_policy_document" "alb_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_irsa_role" {
  name               = "${local.name_prefix}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_irsa_assume.json
  tags               = local.common_tags
}

# Attach ALB Controller IAM Policy
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${local.name_prefix}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
  role       = aws_iam_role.alb_irsa_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

