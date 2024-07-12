variable "prefix" {
    type = string
}

variable "region" {
    type = string
}

variable "environment" {
    type = string
}

variable "codepipeline_role_name" {
    type = string
    default = "cp-service-role"
}

variable "codedeploy_role_name" {
    type = string
    default = "cd-service-role"
}

variable "codecommit_account" {
    type = string
}

variable "codepipeline_role_policy_name" {
    type = string
    default = "cp-service-role-policy"
}

variable "codebuild_role_name" {
    type = string
    default = "cb-service-role"
}

variable "codebuild_role_policy_name" {
    type = string
    default = "cb-service-role-policy"
}

variable "codepipeline_bucket_name" {
    type = string
    default = "codepipeline-bucket"
}

variable "eventbridge_role_name" {
    type = string
    default = "eb-service-role"
}

variable "eventbridge_role_policy_name" {
    type = string
    default = "eb-service-role-policy"
}

variable "web_app_bucket_name" {
    type = string
}

variable "web_app_bucket_arn" {
    type = string
}

variable "source_branch" {
    type = string
}

variable "ecs_cluster_name" {
    type = string
  
}

variable "s3_bucket_name" {
    type = string
}

variable "cf_distribution_id" {
    type = string
}

variable "account_id" {
    type = string
}
