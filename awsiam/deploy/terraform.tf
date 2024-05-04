terraform {
  required_providers {
#    heroku = {
#      source = "heroku/heroku"
#      version = "~> 4.6"
#    }
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
    /*github = {
      source = "integrations/github"
      version = "~> 6.0"
    }*/
  }
}

#provider "heroku" {}

/*provider "github" {}*/

provider "aws" {
  region = "us-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
