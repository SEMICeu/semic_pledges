variable "global_name" {}

# Combine variables
locals {
  num_public_subnets  = 3
  num_private_subnets = 3
  vpc_name            = "${var.global_name}-vpc"
  igw_name            = "${var.global_name}-igw"
  nat_gw_name         = "${var.global_name}-nat-gw"
  sg_default_name     = "${var.global_name}-sg-default-do-not-use"
  log_group_name      = "${var.global_name}-vpc-flowlog"
  subnet_name         = "${var.global_name}-sn"
  route_table_name    = "${var.global_name}-rt"
}

variable "region" {
}

variable "vpc_cidr" {
  default = "10.30.0.0/21"
}

variable "public_cidrs" {
  default = ["10.30.0.0/24", "10.30.1.0/24"]
}

variable "private_cidrs" {
  default = ["10.30.2.0/24", "10.30.3.0/24", "10.30.4.0/24"]
}

variable "log_retention" {
  default = 365
  type    = number
}
