terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
