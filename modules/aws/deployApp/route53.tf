resource "aws_route53_record" "this" {
  zone_id = var.public_zone.id
  name    = var.app_name
  type    = "A"

  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}