resource "aws_kms_key" "ecr" {
  description         = "KMS key used for ecr"
  enable_key_rotation = true
  tags = {
    Name = local.global_name
  }
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${local.global_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}