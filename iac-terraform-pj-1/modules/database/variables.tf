# --- database/variables.tf ---

variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_allocate_storage" {}
variable "db_user" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_password" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "use_replica" {
  type = bool
}

variable "db_subnet_group_name" {}
variable "db_skip_final_snapshot" {}
variable "db_environment" {}
variable "project" {}
variable "region" {}
variable "repository" {}
variable "environment" {}
variable "private_sn_count" {}
variable "db_backup" {}
variable "db_storage_encrypted" {}
variable "db_multi_az" {}