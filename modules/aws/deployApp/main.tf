resource "aws_kms_key" "this" {
  description         = "KMS key used for ecs and efs attached volumes"
  enable_key_rotation = true
  tags                = {
    Name = var.global_name
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.global_name}-${var.app_name}-ecs-efs"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.global_name}-ecs-${var.app_name}"
  retention_in_days = var.log_retention
}

resource "aws_ecs_cluster" "this" {
  name = "${var.global_name}-${var.app_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.this.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}