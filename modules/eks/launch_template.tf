############################################################
# Launch Template for EKS Nodes
############################################################

data "aws_ssm_parameter" "eks_ami" {
  # This path changes depending on your Kubernetes version
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI account ID

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.eks_ami.value]
  }
}

resource "aws_launch_template" "eks_nodes_lt" {
  name_prefix   = "${var.project}-${var.environment}-eks-nodes-"
  image_id      = data.aws_ami.eks_worker.id   # dynamic AMI lookup
  instance_type = "t3.medium"

  key_name = null  # no SSH for private nodes


  network_interfaces {
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }
    # 🔑 Bootstrap script to join the cluster
  user_data = base64encode(<<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.project}-${var.environment}-eks \
      --kubelet-extra-args '--node-labels=role=private'
  EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-eks-node"
      Project     = var.project
      Environment = var.environment
    }
  }
}
