variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  type    = string
}

variable "source_branch" {
  type    = string
}

variable "source_repository_name" {
  type    = string
}

variable "account_id" {
  type = string
}

variable "codepipeline_role_arn" {
  type = string
}

variable "codebuild_role_arn" {
  type = string
}

variable "eventbridge_role_arn" {
  type = string
}

variable "codepipeline_bucket_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "codecommit_account" {
  type = string
}

variable "codebuild_build_path" {
  type    = string
  default = "."
}

variable "codebuild_image_repo_name" {
  type = string
}

variable "codebuild_image_tag" {
  type = string
  default = "latest"
}

variable "ecs_cluster_name" {
  type = string
  default = "pj-cd-acloud-company-dev-ecs-cluster"
}

variable "ecs_service_name" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "eventbridge_rule_description" {
  type = string
  default = "Rule triggered by CodeCommit repository branch changes."
}