output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
