# Required add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.sindhbank.name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.0-eksbuild.1"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.sindhbank.name
  addon_name    = "kube-proxy"
  addon_version = "v1.30.0-eksbuild.1"
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.sindhbank.name
  addon_name    = "coredns"
  addon_version = "v1.10.1-eksbuild.1"
}

# Optional add-ons
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.sindhbank.name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name = aws_eks_cluster.sindhbank.name
  addon_name   = "aws-efs-csi-driver"
}
