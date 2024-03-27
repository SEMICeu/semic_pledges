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

variable "log_retention" {
  description = "Log retention in days"
  default     = 365
  type        = number
}

# Combine variables
locals {
  global_name = "${var.default_tags.customer}-${var.default_tags.project}${var.default_tags.environment != "" ? "-" : ""}${var.default_tags.environment != "" ? var.default_tags.environment : ""}"
}

# VPC variables
variable "vpc" {
  default = {
    cidr          = "10.20.0.0/21"
    public_cidrs  = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
    private_cidrs = ["10.20.4.0/24", "10.20.5.0/24", "10.20.6.0/24"]
  }
  description = "CIDR ranges to use for VPC"
}

# CodeCatalyst variables
variable "codecatalyst_space_id" {
  type    = string
  default = "9ce68442-fd01-4765-9ec0-8f0502a4cf9d"
}

variable "codecatalyst_project_id" {
  type        = string
  default     = "6915d749-8a30-4a17-9dc2-fa8508829c1e"
  description = "The project ID that will be granted the Terraform role"
}

# DNS, using the hosted zone provided by the domain registration
variable "public_zone" {
  default = {
    id     = "Z02659241HH5QDM4SNKZ6"
    domain = "semicai.eu"
  }
}


# Application variables

variable "application_name" {
  type    = string
  default = "pledges"
}

variable "frontend_image" {
  type        = string
  default     = ""
  description = "Only provide a value, if you want to deploy the non-latest tag found"
}

variable "frontend_config" {
  type = object({
    count                    = number
    name                     = string
    cpu                      = number
    memory                   = number
    container_port           = number
    host_port                = number
    quicksight_dashboard_ids = list(string)
    white_listed_ips         = list(map(string))
  })
  default = ({
    count                    = 1
    name                     = "frontend"
    cpu                      = 2048
    memory                   = 8192
    container_port           = 4443
    host_port                = 4443
    quicksight_dashboard_ids = ["c0ab1fea-58e4-410f-a286-fb16dc6b49e0"]
    white_listed_ips = [
      {
        "thierry.turpin@pwc.com"                           = "213.118.27.121/32"
        "stanko.dimitrov@pwc.com"                          = "208.127.60.143/32"
        "piriya.sivalingam@pwc.com"                        = "112.134.187.15/32"
        "PwC_Antwerp_wifi"                                 = "84.198.223.14/32"
        "PwC_Antwerp_guest_wifi"                           = "208.127.140.35/32"
        "PwC_BXL_guest_wifi"                               = "134.238.50.213/32"
        "PwC_remote"                                       = "208.127.60.144/32"
        "EC Public IP for WIFI"                            = "147.67.4.96/27"
        "EC Public IP for WIFI"                            = "147.67.241.224/27"
        "EC Public IP for the wired network (via the VPN)" = "158.169.40.0/27"
        "EC Public IP for the wired network (via the VPN)" = "158.169.150.0/27"
      }
    ]
  })
}

variable "backend_image" {
  type        = string
  default     = ""
  description = "Only provide a value, if you want to deploy the non-latest tag found"
}

variable "backend_config" {
  type = object({
    count          = number
    name           = string
    cpu            = number
    memory         = number
    container_port = number
    host_port      = number
  })
  default = ({
    count          = 1
    name           = "backend"
    cpu            = 2048
    memory         = 8192
    container_port = 4443
    host_port      = 4443
  })
}