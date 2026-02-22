terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "sindhbank-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    #use_lockfile = true
    dynamodb_table = "sindhbank-terraform-lock"
    encrypt        = true
  }
}
