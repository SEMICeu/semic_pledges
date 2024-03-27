############################
# Pledges application on ECS
############################

module "AWS-deployApp" {
  source          = "../../modules/aws/deployApp"
  global_name     = local.global_name
  app_name        = var.application_name
  log_retention   = var.log_retention
  private_cidrs   = var.vpc.private_cidrs
  public_zone     = var.public_zone
  vpc_id          = module.AWS-deployVPC.vpc-id
  private_subnets = module.AWS-deployVPC.private-subnet-ids
  public_subnets  = module.AWS-deployVPC.public-subnet-ids
  frontend_config = var.frontend_config
  certificate_arn = aws_acm_certificate.frontend.arn
  frontend_image  = coalesce(var.frontend_image, "${data.aws_ecr_repository.frontend.repository_url}:${data.aws_ecr_repository.frontend.most_recent_image_tags[0]}")
  backend_config  = var.backend_config
  backend_image   = coalesce(var.backend_image, "${data.aws_ecr_repository.backend.repository_url}:${data.aws_ecr_repository.backend.most_recent_image_tags[0]}")
  default_tags    = var.default_tags
  region          = var.AWS_region
}


resource "aws_ecr_repository" "frontend" {
  name                 = "${local.global_name}-${var.frontend_config.name}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${local.global_name}-${var.backend_config.name}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
