module "company" {
  source            = "../../company"
  environment       = "uat"
  aws_region        = "eu-west-1"
  vpc_cidr          = "10.2.0.0/16"
  db_instance_class = "db.t3.small"
  source_branch     = "uat"
  eu-west-1_certificate = "arn:aws:acm:eu-west-1:176666047687:certificate/4753c91f-f950-4c84-acbf-b83b9197fc87"
  us-east-1_certificate = "arn:aws:acm:us-east-1:176666047687:certificate/6c64cf57-f4f8-4fa4-9345-c648f00c5d10"
  domain = "uat.company.com"
}

terraform {
  backend "s3" {
    bucket = "tfstate-176666047687"
    key    = "uat/remote-state/terraform.tfstate"
    region = "eu-west-1"
  }
}