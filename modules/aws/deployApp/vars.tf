variable "global_name" { type = string }

variable "app_name" { type = string }

variable "default_tags" { type = map(string) }

variable "region" {}

variable "log_retention" {
  default = 365
  type    = number
}

variable "public_zone" {}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {}
variable "public_subnets" {}

variable "private_cidrs" {
  type = list(string)
}

variable "frontend_image" { type = string }

variable "certificate_arn" { type = string }

variable "s3_object_expiration_days" {
  type = number
  default = 6
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
}

variable "backend_image" { type = string }

variable "backend_config" {
  type = object({
    count          = number
    name           = string
    cpu            = number
    memory         = number
    container_port = number
    host_port      = number
  })
}