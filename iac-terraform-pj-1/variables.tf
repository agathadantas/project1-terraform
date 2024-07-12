# --- root/variables.tf ---

variable "aws_region" {
  default = "eu-west-1"
}

variable "environment" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "source_branch" {
  type = string
}

variable "us-east-1_certificate" {
  type = string
}

variable "eu-west-1_certificate" {
  type = string
}

variable "domain" {
  type = string
}

variable "use_replica" {
  type = bool
  default = true
}
