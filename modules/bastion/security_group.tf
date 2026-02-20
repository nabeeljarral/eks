# Private bastion security group


resource "aws_security_group" "bastion_sg" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security Group for Bastion EC2 - SSM Only"
  vpc_id      = var.vpc_id

  # No inbound from internet (deny all)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  # Outbound allowed via NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-bastion-sg"
    Module      = "bastion"
  })
}
