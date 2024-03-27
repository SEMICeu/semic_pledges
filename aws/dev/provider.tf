############################
# Providers
############################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region              = var.AWS_region
  allowed_account_ids = var.AWS_account_ids
  default_tags {
    tags = {
      customer    = var.default_tags.customer
      project     = var.default_tags.project
      environment = var.default_tags.environment
      global_name = local.global_name
      deployed_by = "terraform"
    }
  }
}
