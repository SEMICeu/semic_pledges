data "aws_caller_identity" "current" {}

data "aws_ecr_repository" "frontend" {
  name = aws_ecr_repository.frontend.name
}

data "aws_ecr_repository" "backend" {
  name = aws_ecr_repository.backend.name
}