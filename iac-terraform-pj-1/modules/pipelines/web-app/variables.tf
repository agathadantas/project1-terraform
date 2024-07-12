variable "prefix" {

}

variable "region" {

}

variable "service_name" {
    default = "web-app"
}

variable "source_branch" {
    default = "develop"
}

variable "source_repository_name" {
}

variable "kms_key_arn" {
  type = string
}

variable "codebuild_project_name" {
  default = "codebuild-web-app"
}

variable "codecommit_account" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "cf_distribution_id" {
  type = string
}

variable "codepipeline_role_arn" {

}

variable "codebuild_role_arn" {

}
# variable "codedeploy_role_arn" {
  
# }
variable "eventbridge_role_arn" {

}
variable "environment" {
}

variable "codepipeline_bucket_id" {
    
}
variable "web_app_bucket_name" {
    
}
variable "eventbridge_rule_description" {
  default = "Rule triggered by CodeCommit repository branch changes."
}