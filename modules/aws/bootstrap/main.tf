
module "AWS-deploy-bootstrap-bucket" {
  source       = "../deployS3AES"
  global_name  = var.global_name
  default_tags = var.default_tags
  bucket_name  = "${var.global_name}-terraform-state"
}

resource "aws_dynamodb_table" "lock" {
  name           = "${var.global_name}-terraform-state"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}