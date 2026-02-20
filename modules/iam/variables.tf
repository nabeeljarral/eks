variable "project" {
  description = "Project name (e.g., sindhbank)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}
variable "oidc_provider_url" {
  type        = string
  description = "OIDC issuer URL from EKS cluster"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
