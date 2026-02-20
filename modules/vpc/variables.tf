variable "project" {
  type        = string
  default     = "sindhbank"
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name (prod/dev)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  description = "Private subnet CIDRs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
