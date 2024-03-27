module "AWS-deploy-input-bucket" {
  source       = "../deployS3AES"
  global_name  = var.global_name
  default_tags = var.default_tags
  bucket_name  = "${var.global_name}-${var.app_name}-raw-input"
}

resource "aws_s3_bucket_notification" "input" {
  bucket      = module.AWS-deploy-input-bucket.bucket_id
  eventbridge = true
}

resource "aws_s3_bucket_lifecycle_configuration" "input" {
  bucket = module.AWS-deploy-input-bucket.bucket_id
  rule {
    id = "all"
    expiration {
      days = var.s3_object_expiration_days
    }
    status = "Enabled"
  }
}

module "AWS-deploy-output-bucket" {
  source       = "../deployS3AES"
  global_name  = var.global_name
  default_tags = var.default_tags
  bucket_name  = "${var.global_name}-${var.app_name}-raw-output"
}

resource "aws_s3_bucket_lifecycle_configuration" "output" {
  bucket = module.AWS-deploy-output-bucket.bucket_id
  rule {
    id = "all"
    expiration {
      days = var.s3_object_expiration_days
    }
    status = "Enabled"
  }
}


module "AWS-deploy-model-bucket" {
  source       = "../deployS3AES"
  global_name  = var.global_name
  default_tags = var.default_tags
  bucket_name  = "${var.global_name}-${var.app_name}-model"
}