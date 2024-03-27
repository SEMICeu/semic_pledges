
module "AWS-deploy-bootstrap" {
  source       = "../../modules/aws/bootstrap"
  global_name  = local.global_name
  default_tags = var.default_tags
}