variable "ecs_subnets" {}
variable "ecs_container_port" {
  type = number
}
variable "project" {}
variable "region" {}
variable "repository" {}
variable "environment" {}

variable "vpc_cidr" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_identifier" {}

variable "db_url" {
  type = string
}

variable "user-service_tg_arn" {
  type = string
}
variable "appointment-service_tg_arn" {
  type = string
}

variable "notification-service_tg_arn" {
  type = string
}

variable "user-service-int_tg_arn" {
  type = string
}
variable "appointment-service-int_tg_arn" {
  type = string
}

variable "notification-service-int_tg_arn" {
  type = string
}

variable "account_id" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "cognito_secret_arn" {
  type = string
}

variable "email_secret_arn" {
  type = string
}

variable "knok_secret_arn" {
  type = string
}

variable "elb_url" {
  type = string
}

variable "domain" {
  type = string
}