provider "aws" {
  region = "us-east-1"
}

# ---------------------------
# VPC MODULE
# ---------------------------
module "vpc" {
  source      = "../../modules/vpc"
  project     = var.project
  environment = var.environment

  # Only override tags if needed
  tags = {
    Owner = "SindhBank-InfraTeam"
  }
}

# ---------------------------
# IAM MODULE
# ---------------------------
module "iam" {
  source      = "../../modules/iam"
  project     = var.project
  environment = var.environment
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  tags = {
    Owner = "SindhBank-InfraTeam"
  }
}

# ---------------------------
# Secrets MODULE
# ---------------------------

module "sindhbank_secret" {
  source      = "../../modules/secrets"
  secret_name = "sindhbank-prod-rds-credentials"
}



module "bastion" {
  source = "../../modules/bastion"

  project          = var.project
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_ids[0]   # FIXED NAME
  instance_profile = module.iam.bastion_instance_profile
    tags = {
    Owner = "SindhBank-InfraTeam"
  }
}


module "eks" {
  source = "../../modules/eks"

  project          = var.project
  environment      = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_nodegroup_role_arn

}
