resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.global_name}-${var.backend_config.name}"
  network_mode             = "awsvpc"
  cpu                      = var.backend_config.cpu
  memory                   = var.backend_config.memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.backend.arn

  task_role_arn = aws_iam_role.backend.arn
  volume {
    name = "model"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.this.id
      root_directory = "/Word2Vec/"

    }
  }

  container_definitions = jsonencode([
    {
      name         = var.backend_config.name
      image        = var.backend_image
      cpu          = var.backend_config.cpu
      memory       = var.backend_config.memory
      essential    = true
      environment  = [{ "name" : "SECRET_NAME", "value" : aws_secretsmanager_secret.backend.name }],
      mountPoints  = [{ "sourceVolume" : "model", "containerPath" : "/app/model/Word2Vec", "readOnly" : true }]
      portMappings = [
        {
          containerPort = var.backend_config.container_port
          hostPort      = var.backend_config.host_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.global_name}-${var.backend_config.name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_iam_role_policy_attachment" "backend" {
  role       = aws_iam_role.backend.name
  policy_arn = aws_iam_policy.backend.arn
}

resource "aws_iam_role" "backend" {
  name               = "${var.global_name}-ecs-${var.app_name}-${var.backend_config.name}"
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

resource "aws_iam_policy" "backend" {
  name        = "${var.global_name}-ecs-${var.app_name}-${var.backend_config.name}"
  path        = "/"
  description = "Policy for the ${var.app_name} ${var.backend_config.name}"
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
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.backend.name_prefix}*"
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
      }
    ]
  })
}

