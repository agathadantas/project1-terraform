variable "https_listeners" {
  type    = any
  default = []
}
variable "public_sg" {}
variable "public_subnets" {}
variable "vpc_cidr" {}
variable "ecs_cluster_name" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "vpc_id" {}
variable "lb_health_threshold" {}
variable "lb_unhealth_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "lb_health_check_path" {}
variable "listener_port" {}
variable "listener_protocol" {}
variable "project" {}
variable "region" {}
variable "repository" {}
variable "environment" {}

variable "eu-west-1_certificate" {
  type = string
}