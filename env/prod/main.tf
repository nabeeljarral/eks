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

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  vpc_cidr           = module.vpc.vpc_cidr 
  cluster_role_arn    = module.iam.cluster_role_arn
  node_role_arn       = module.iam.node_role_arn
}
