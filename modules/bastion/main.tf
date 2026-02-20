locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, { Project     = var.project, Environment = var.environment})
}

###########################################################
# Latest Amazon Linux 2 AMI
###########################################################  
data "aws_ami" "amazon_linux" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  most_recent = true
}

###########################################################
# Bastion EC2 instance with userdata script
###########################################################  
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  iam_instance_profile = var.instance_profile

  # No keypair, SSM only
  key_name = null

  # Run userdata script on boot
  user_data = file("${path.module}/userdata.sh")

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
  })
}

###########################################################
# Auto-update SSM agent
###########################################################
resource "aws_ssm_association" "update_ssm" {
  name = "AWS-UpdateSSMAgent"
  targets {
    key    = "InstanceIds"
    values = [aws_instance.bastion.id]
  }
}
