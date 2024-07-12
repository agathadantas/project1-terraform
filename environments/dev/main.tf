module "company" {
  source            = "../../company"
  environment       = "dev"
  aws_region        = "eu-west-1"
  vpc_cidr          = "10.0.0.0/16"
  db_instance_class = "db.t3.small"
  source_branch     = "develop"
  eu-west-1_certificate = "arn:aws:acm:eu-west-1:315120513061:certificate/e263398c-bb10-4cd2-989d-5fe47755ed74"
  us-east-1_certificate = "arn:aws:acm:us-east-1:315120513061:certificate/db513abd-3bca-45ef-a53e-df9d0a271d2f"
  domain = "dev.company.com"
  use_replica = false
}

terraform {
  backend "s3" {
    bucket = "tfstate-315120513061"
    key    = "dev/remote-state/terraform.tfstate"
    region = "eu-west-1"
  }
}