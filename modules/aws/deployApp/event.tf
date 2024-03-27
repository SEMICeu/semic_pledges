resource "aws_cloudwatch_event_rule" "s3_file" {
  name        = "${var.global_name}-${var.frontend_config.name}"
  description = "Capture new object received in bucket"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : ["${var.global_name}-${var.app_name}-raw-input"]
      }
    }
  })
}

# todo use jsonencode instead

resource "aws_cloudwatch_event_target" "backend" {
  target_id = "${var.global_name}-${var.backend_config.name}"
  arn       = aws_ecs_cluster.this.arn
  rule      = aws_cloudwatch_event_rule.s3_file.name
  role_arn  = aws_iam_role.event.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = replace(aws_ecs_task_definition.backend.arn, "/:\\d+$/", "")
    launch_type         = "FARGATE"
    network_configuration {
      subnets         = var.private_subnets
      security_groups = [aws_security_group.backend.id]
    }
  }

  input_transformer {
    input_paths = {
      bucket_name = "$.detail.bucket.name",
      object_key  = "$.detail.object.key",
    }
    input_template = <<EOF
{
  "containerOverrides": [
    {
      "name": "backend",
      "environment" : [
        {
          "name" : "BUCKET_NAME",
          "value" : <bucket_name>
        },
        {
          "name" : "OBJECT_KEY",
          "value" : <object_key>
        }
      ]
    }
  ]
}
EOF
  }

}

resource "aws_security_group" "backend" {
  description = "${var.global_name}-${var.backend_config.name}"
  vpc_id      = var.vpc_id
  name        = "${var.global_name}-${var.backend_config.name}"
  tags        = {
    Name = "${var.global_name}-${var.backend_config.name}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sf_backend_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}

resource "aws_iam_role_policy_attachment" "event" {
  role       = aws_iam_role.event.name
  policy_arn = aws_iam_policy.event.arn
}

resource "aws_iam_role" "event" {
  name               = "${var.global_name}-${var.app_name}-${var.frontend_config.name}-trigger"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "events.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "event" {
  name        = "${var.global_name}-${var.app_name}-${var.frontend_config.name}-trigger"
  path        = "/"
  description = "Policy for the ${var.app_name} ${var.frontend_config.name} to trigger ECS task"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "ECS",
        Effect : "Allow",
        Action : [
          "ecs:RunTask"
        ],
        Resource : [
          replace(aws_ecs_task_definition.backend.arn, "/:\\d+$/", ":*"),
          replace(aws_ecs_task_definition.backend.arn, "/:\\d+$/", "")
        ],
        Condition : {
          ArnLike : {
            "ecs:cluster" : aws_ecs_cluster.this.arn
          }
        }
      },
      {
        Sid : "IAM",
        Effect : "Allow",
        Action : "iam:PassRole",
        Resource : ["*"],
        Condition : {
          StringLike : {
            "iam:PassedToService" : "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

