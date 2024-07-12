module "company" {
  source            = "../../company"
  environment       = "prod"
  aws_region        = "eu-west-1"
  vpc_cidr          = "10.3.0.0/16"
  db_instance_class = "db.t3.small"
  source_branch     = "master"
  eu-west-1_certificate = "arn:aws:acm:eu-west-1:237091217375:certificate/d89a8fe8-21ff-43dd-b279-fb648f843699"
  us-east-1_certificate = "arn:aws:acm:us-east-1:237091217375:certificate/c4c19cd9-e5b8-4e43-9616-94d307b8ca71"
  domain = "company.com"
}

terraform {
  backend "s3" {
    bucket = "tfstate-237091217375"
    key    = "prod/remote-state/terraform.tfstate"
    region = "eu-west-1"
  }
}