variable "branch" {
  type = string
  default = "main"
}

variable "repo" {
  default = "j2clark/terraform-examples-aws-apigateway"
}

variable "project_name" {
  default = "examples-apigateway"
}

locals {
  name_prefix  = "${var.project_name}-apikey-${var.branch}"
  region       = data.aws_region.current.id
  account_id   = data.aws_caller_identity.current.id
#  project_name = var.project_name
  github_repo  = var.repo
  application  = "apikey"

  common_tags = {
    ProjectName = var.project_name
    Application = "apikey"
    Github = var.repo
    Branch = var.branch
  }
}
