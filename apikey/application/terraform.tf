terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}