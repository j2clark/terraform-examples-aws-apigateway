variable "name_prefix" {
  type = string
}

variable "cors_origin" {
  type = string
  default = "*"
}

locals {
  region       = data.aws_region.current.id
  account_id   = data.aws_caller_identity.current.id
  max_retries  = 0
  timeout      = 5
  max_concurrent_runs = 1

  common_tags = {
    Example = var.name_prefix
  }
}
