resource "aws_sqs_queue" "this" {
  name                    = "${var.global_name}-${var.app_name}"
  sqs_managed_sse_enabled = true
}
