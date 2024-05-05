variable "branch" {
  type = string
  default = "main"
}

variable "repo" {
  default = "j2clark/terraform-examples-aws-apigateway"
}

variable "project_name" {
  default = "examples-apigateway-cognito"
}

locals {
  name_prefix  = "${var.project_name}-${var.branch}"
  region       = data.aws_region.current.id
  account_id   = data.aws_caller_identity.current.id

  common_tags = {
    ProjectName = var.project_name
    Github = var.repo
    Branch = var.branch
  }
}
