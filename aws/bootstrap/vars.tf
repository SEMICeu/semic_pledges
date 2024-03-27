#############################
# Vars
#############################
# Provider level
variable "AWS_account_ids" {
  default     = ["***"]
  description = "List of allowed accounts"
}


variable "AWS_region" {
  default     = "eu-west-1"
  description = "the AWS region to use, QuickSight currently only supports Frankfurt, Ireland, London (eu-central-1, eu-west-1, eu-west-2) in the EU"
}

# General variables
variable "default_tags" {
  default = {
    customer    = "digit"
    project     = "semic"
    environment = "dev"

  }
  description = "Default Tags, only user lower case"
  type        = map(string)
}

# Combine variables
locals {
  global_name = "${var.default_tags.customer}-${var.default_tags.project}${var.default_tags.environment != "" ? "-" : ""}${var.default_tags.environment != "" ? var.default_tags.environment : ""}"
}