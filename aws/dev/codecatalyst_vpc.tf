# CodeCatalyst VPC IAM

resource "aws_iam_policy" "codecatalyst_vpc" {
  name        = "${local.global_name}-codecatalyst-vpc"
  path        = "/"
  description = "Policy for codecatalyst vpc access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "EC2",
        Effect : "Allow",
        Action : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:CreateTags",
          "ec2:DescribeVpcs"
        ],
        Resource : "*",
      },
      {
        Sid : "EC2CreateNetworkInterfacePermission",
        Effect : "Allow",
        Action : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource : "arn:aws:ec2:${var.AWS_region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      },
      {
        Sid : "ec2CreateTags",
        Effect : "Allow",
        Action : [
          "ec2:CreateTags"
        ],
        Condition : {
          StringEquals : {
            "ec2:CreateAction" : "CreateNetworkInterface"
          },
          "ForAnyValue:StringEquals" : {
            "aws:TagKeys" : "ManagedByCodeCatalyst"
          }
        },
        Resource : "arn:aws:ec2:${var.AWS_region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codecatalyst_vpc" {
  role       = aws_iam_role.codecatalyst_vpc.name
  policy_arn = aws_iam_policy.codecatalyst_vpc.arn
}

resource "aws_iam_role" "codecatalyst_vpc" {
  name = "${local.global_name}-codecatalyst-vpc"
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

resource "aws_security_group" "codecatalyst_vpc" {
  description = "${local.global_name}-codecatalyst-vpc"
  vpc_id      = module.AWS-deployVPC.vpc-id
  name        = "${local.global_name}-codecatalyst-vpc"
  tags = {
    Name = "${local.global_name}-codecatalyst-vpc"
  }
}

resource "aws_security_group_rule" "codecatalyst_vpc_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.codecatalyst_vpc.id
}