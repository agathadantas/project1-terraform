data "aws_caller_identity" "current" {}

module "networking" {
  source           = "./modules/networking"
  vpc_cidr         = var.vpc_cidr
  security_groups  = local.security_groups
  public_sn_count  = 2
  private_sn_count = 4
  max_subnets      = 6
  project          = "company"
  region           = var.aws_region
  repository       = ""
  environment      = var.environment
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  db_subnet_group  = true
}

module "db_secret" {
  source      = "./modules/secretsmanager"
  environment = var.environment
  project     = module.networking.project_name
  region      = module.networking.region
  repository  = module.networking.repository
}

module "database" {
  source                 = "./modules/database"
  private_sn_count       = module.networking.private_subnets
  db_environment         = var.environment
  db_engine              = "postgres"
  db_engine_version      = "14.7"
  db_instance_class      = var.db_instance_class
  db_allocate_storage    = "50"
  db_user                = "company${var.environment}"
  db_name                = "company${var.environment}db"
  db_password            = module.db_secret.secret_value
  db_subnet_group_name   = module.networking.db_subnet_group_name
  db_skip_final_snapshot = true
  project                = module.networking.project_name
  region                 = module.networking.region
  repository             = module.networking.repository
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  vpc_id                 = module.networking.vpc_id
  db_backup              = 7
  db_storage_encrypted   = true
  db_multi_az            = true
  use_replica            = var.use_replica
}

module "ecs" {
  source                          = "./modules/ecs"
  vpc_cidr                        = var.vpc_cidr
  vpc_id                          = module.networking.vpc_id
  ecs_container_port              = "80"
  user-service_tg_arn             = module.loadbalancing.user-service_tg_arn
  appointment-service_tg_arn      = module.loadbalancing.appointment-service_tg_arn
  notification-service_tg_arn     = module.loadbalancing.notification-service_tg_arn
  appointment-service-int_tg_arn  = module.loadbalancing.appointment-service-int_tg_arn
  notification-service-int_tg_arn = module.loadbalancing.notification-service-int_tg_arn
  user-service-int_tg_arn         = module.loadbalancing.user-service-int_tg_arn
  ecs_subnets                     = module.networking.private_subnets
  project                         = module.networking.project_name
  region                          = module.networking.region
  repository                      = module.networking.repository
  environment                     = var.environment
  vpc_identifier                  = module.networking.public_subnets
  db_secret_arn                   = module.db_secret.db_secret_arn
  cognito_secret_arn              = module.db_secret.cognito_secret_arn
  email_secret_arn                = module.db_secret.email_secret_arn
  elb_url                         = module.loadbalancing.elb_url
  knok_secret_arn                 = module.db_secret.knok_secret_arn
  db_url                          = module.database.db_url
  domain                          = var.domain
  account_id                      = data.aws_caller_identity.current.account_id
}


module "loadbalancing" {
  source                = "./modules/loadbalancing"
  public_sg             = module.networking.public_sg
  public_subnets        = module.networking.public_subnets
  vpc_cidr              = module.networking.vpc_id
  ecs_cluster_name      = module.ecs.cluster
  tg_port               = 80
  tg_protocol           = "HTTP"
  vpc_id                = module.networking.vpc_id
  lb_health_threshold   = 2
  lb_unhealth_threshold = 2
  lb_timeout            = 3
  lb_interval           = 30
  lb_health_check_path  = "/"
  listener_port         = 80
  listener_protocol     = "HTTP"
  project               = module.networking.project_name
  region                = module.networking.region
  repository            = module.networking.repository
  environment           = var.environment
  eu-west-1_certificate = var.eu-west-1_certificate
}

module "ecr" {
  source      = "./modules/ecr"
  project     = module.networking.project_name
  region      = module.networking.region
  repository  = module.networking.repository
  environment = var.environment
}

#module "cognito" {
#  source      = "./modules/cognito"
#  project     = module.networking.project_name
#  region      = module.networking.region
#  repository  = module.networking.repository
#  environment = var.environment
#}

#module "apigateway" {
#  source      = "./modules/apigateway"
#  project     = module.networking.project_name
#  region      = module.networking.region
#  repository  = module.networking.repository
#  environment = var.environment
#}

module "bucket" {
  source                = "./modules/bucket"
  project               = module.networking.project_name
  region                = module.networking.region
  repository            = module.networking.repository
  environment           = var.environment
  us-east-1_certificate = var.us-east-1_certificate
  domain                = var.domain
  codebuild_role        = module.pipelines.codebuild_role
}

module "pipelines" {
  source              = "./modules/pipelines"
  prefix              = "project-pt-${var.environment}"
  region              = var.aws_region
  environment         = var.environment
  web_app_bucket_name = module.bucket.bucket_name
  web_app_bucket_arn  = module.bucket.bucket_arn
  source_branch       = var.source_branch
  ecs_cluster_name    = module.ecs.cluster
  codecommit_account  = "315120513061"
  cf_distribution_id  = module.bucket.cf_distribution_id
  s3_bucket_name      = module.bucket.s3_bucket_name
  account_id          = data.aws_caller_identity.current.account_id
}