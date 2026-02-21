variable "project" {}
variable "environment" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {}
variable "vpc_id" {
  type = string
  description = "VPC ID where EKS cluster and SGs will be created"
}
variable "node_role_arn" {}
variable "tags" {
  description = "Global tags applied to all resources"
  type        = map(string)
}



