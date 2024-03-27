resource "aws_acm_certificate" "frontend" {
  domain_name       = "*.${var.public_zone.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}