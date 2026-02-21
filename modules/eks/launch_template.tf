data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI owner

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.30-v*"]
  }
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.project}-${var.environment}-eks-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-private-ng"
      Project     = var.project
      Environment = var.environment
      Owner       = "SindhBank-InfraTeam"
    }
  }
}
