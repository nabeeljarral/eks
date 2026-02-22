variable "project" {}
variable "environment" {}

variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {}
variable "node_role_arn" {}

variable "kubernetes_version" {
  default = "1.33"
}

variable "vpc_cidr" {}
variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}

