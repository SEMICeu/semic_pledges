# IAM for docker build and push to ECR

resource "aws_iam_role_policy_attachment" "codecatalyst_workflow_docker" {
  role       = aws_iam_role.codecatalyst_workflow_docker.name
  policy_arn = aws_iam_policy.codecatalyst_workflow_docker.arn
}

resource "aws_iam_role" "codecatalyst_workflow_docker" {
  name = "${local.global_name}-codecatalyst-workflow-docker"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "codecatalyst-runner.amazonaws.com",
            "codecatalyst.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : [
              "arn:aws:codecatalyst:::space/${var.codecatalyst_space_id}/project/*",
              "arn:aws:codecatalyst:::space/${var.codecatalyst_space_id}"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codecatalyst_workflow_docker" {
  name        = "${local.global_name}-codecatalyst-workflow-docker"
  path        = "/"
  description = "Policy for codecatalyst workflow docker image build"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "EC2",
        Effect : "Allow",
        Action : [
          "ecr:*"
        ],
        Resource : "*",
      }
    ]
  })
}

# IAM role for Terraform workflow run

resource "aws_iam_role_policy_attachment" "codecatalyst_workflow_terraform" {
  role       = aws_iam_role.codecatalyst_workflow_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "codecatalyst_workflow_terraform" {
  name = "${local.global_name}-codecatalyst-worfklow-terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "codecatalyst-runner.amazonaws.com",
            "codecatalyst.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : [
              "arn:aws:codecatalyst:::space/${var.codecatalyst_space_id}/project/${var.codecatalyst_project_id}",
              "arn:aws:codecatalyst:::space/${var.codecatalyst_space_id}"
            ]
          }
        }
      }
    ]
  })
}