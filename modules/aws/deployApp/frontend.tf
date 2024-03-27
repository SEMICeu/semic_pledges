resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.global_name}-${var.frontend_config.name}"
  network_mode             = "awsvpc"
  cpu                      = var.frontend_config.cpu
  memory                   = var.frontend_config.memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.frontend.arn

  task_role_arn         = aws_iam_role.frontend.arn
  container_definitions = jsonencode([
    {
      name         = var.frontend_config.name
      image        = var.frontend_image
      cpu          = var.frontend_config.cpu
      memory       = var.frontend_config.memory
      essential    = true
      environment  = [{ "name" : "SECRET_NAME", "value" : aws_secretsmanager_secret.frontend.name }],
      portMappings = [
        {
          containerPort = var.frontend_config.container_port
          hostPort      = var.frontend_config.host_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.global_name}-${var.frontend_config.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.global_name}-ecs-${var.frontend_config.name}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
  health_check_grace_period_seconds = 3
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_config.container_port
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_service.id]
  }
}

resource "aws_security_group" "ecs_service" {
  description = "${var.global_name}-ecs-${var.frontend_config.name}"
  vpc_id      = var.vpc_id
  name        = "${var.global_name}-ecs-${var.frontend_config.name}"
  tags        = {
    Name = "${var.global_name}-ecs-${var.frontend_config.name}"
  }
}

resource "aws_security_group_rule" "ecs_service_ingress" {
  type                     = "ingress"
  from_port                = var.frontend_config.container_port
  to_port                  = var.frontend_config.container_port
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_service_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.global_name}-ecs-${var.frontend_config.name}"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    protocol = "HTTPS"
    port     = var.frontend_config.container_port
  }
}

resource "aws_lb" "frontend" {
  name               = "${var.global_name}-ecs-${var.frontend_config.name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_security_group" "lb" {
  description = "${var.global_name}-lb-${var.frontend_config.name}"
  vpc_id      = var.vpc_id
  name        = "${var.global_name}-lb-${var.frontend_config.name}"
  tags        = {
    Name = "${var.global_name}-lb-${var.frontend_config.name}"
  }
}

resource "aws_security_group_rule" "lb_ingress" {
  for_each          = tomap(var.frontend_config.white_listed_ips[0])
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  description       = each.key
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_iam_role_policy_attachment" "frontend" {
  role       = aws_iam_role.frontend.name
  policy_arn = aws_iam_policy.frontend.arn
}

resource "aws_iam_role" "frontend" {
  name               = "${var.global_name}-ecs-${var.app_name}-${var.frontend_config.name}"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "ecs-tasks.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "frontend" {
  name        = "${var.global_name}-ecs-${var.app_name}-${var.frontend_config.name}"
  path        = "/"
  description = "Policy for the ${var.app_name} ${var.frontend_config.name}"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "CWAndECR",
        Effect : "Allow",
        Action : [
          "logs:*",
          "ecr:*"
        ],
        Resource : "*",
      },
      {
        Sid : "s3",
        Effect : "Allow",
        Action : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions",
          "s3:ListBucket",
          "s3:ListMultipartUploadParts"
        ],
        Resource : [
          "arn:aws:s3:::${module.AWS-deploy-input-bucket.bucket_id}",
          "arn:aws:s3:::${module.AWS-deploy-input-bucket.bucket_id}/*",
          "arn:aws:s3:::${module.AWS-deploy-output-bucket.bucket_id}",
          "arn:aws:s3:::${module.AWS-deploy-output-bucket.bucket_id}/*",
        ],
      },
      {
        Sid : "Secrets",
        Effect : "Allow",
        Action : [
          "secretsmanager:ListSecrets",
          "secretsmanager:GetSecretValue"
        ],
        Resource : [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.frontend.name_prefix}*"
        ],
      },
      {
        Sid : "KMS",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        Resource : [
          aws_kms_key.this.arn
        ],
      },

      {
        "Sid" : "SQS",
        "Effect" : "Allow",
        "Action" : [
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ],
        "Resource" : [
          aws_sqs_queue.this.arn
        ]
      },
      {
        "Sid" : "QuickSightAnonymousUser",
        "Effect" : "Allow",
        "Action" : [
          "quicksight:GenerateEmbedUrlForAnonymousUser"
        ],
        "Resource" : concat(
          ["arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:namespace/*"],
          [
            for dashboard_id in var.frontend_config.quicksight_dashboard_ids :
            "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:dashboard/${dashboard_id}"
          ]
        )
      },
      {
        "Sid" : "QuickSightEmbed",
        "Effect" : "Allow",
        "Action" : [
          "quicksight:GetDashboardEmbedUrl",
          "quicksight:GetAnonymousUserEmbedUrl"
        ],
        "Resource" : concat(
          [
            for dashboard_id in var.frontend_config.quicksight_dashboard_ids :
            "arn:aws:quicksight:${var.region}:${data.aws_caller_identity.current.account_id}:dashboard/${dashboard_id}"
          ]
        )
      }
    ]
  })
}

