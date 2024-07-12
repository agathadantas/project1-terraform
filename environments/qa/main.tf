module "company" {
  source            = "../../company"
  environment       = "qa"
  aws_region        = "eu-west-1"
  vpc_cidr          = "10.1.0.0/16"
  db_instance_class = "db.t3.small"
  source_branch     = "qa"
  eu-west-1_certificate = "arn:aws:acm:eu-west-1:874396965449:certificate/5122e689-fff3-442c-80a4-3318ced75143"
  us-east-1_certificate = "arn:aws:acm:us-east-1:874396965449:certificate/054cfd60-46b2-465a-b181-b4e296fd84b7"
  domain = "qa.company.com"
  use_replica = false
}

terraform {
  backend "s3" {
    bucket = "tfstate-874396965449"
    key    = "qa/remote-state/terraform.tfstate"
    region = "eu-west-1"
  }
}