variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Bastion SG"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet for Bastion EC2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_profile" {
  type        = string
  description = "IAM instance profile from IAM module"
}

variable "tags" {
  type    = map(string)
  default = {}
}
