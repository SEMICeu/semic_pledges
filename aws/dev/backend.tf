############################
# Backend
############################
terraform {
  backend "s3" {
    bucket         = "digit-semic-dev-terraform-state"
    key            = "aws/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "digit-semic-dev-terraform-state"
  }
}
