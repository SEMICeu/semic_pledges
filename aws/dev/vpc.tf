############################
# VPC
############################

module "AWS-deployVPC" {
  source = "../../modules/aws/deployVPC"
  region = var.AWS_region

  vpc_cidr      = var.vpc.cidr
  public_cidrs  = var.vpc.public_cidrs
  private_cidrs = var.vpc.private_cidrs
  global_name   = local.global_name
  log_retention = var.log_retention
}