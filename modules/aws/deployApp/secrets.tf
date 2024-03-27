resource "aws_secretsmanager_secret" "frontend" {
  name_prefix = "${var.global_name}-${var.app_name}-frontend-"
  kms_key_id  = aws_kms_key.this.key_id
}

resource "aws_secretsmanager_secret" "backend" {
  name_prefix = "${var.global_name}-${var.app_name}-backend-"
  kms_key_id  = aws_kms_key.this.key_id
}