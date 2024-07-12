resource "aws_codepipeline" "web_app_pipeline" {
  name     = "${var.prefix}-${var.service_name}"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_bucket_id
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      region           = var.region
      version          = "1"
      output_artifacts = ["${var.prefix}-${var.service_name}-source"]
      role_arn         = "arn:aws:iam::${var.codecommit_account}:role/CodeCommit_crossAccount"

      configuration = {
        PollForSourceChanges = false
        RepositoryName       = var.source_repository_name
        BranchName           = var.source_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.prefix}-${var.service_name}-source"]
      output_artifacts = ["${var.prefix}-${var.service_name}-build"]
      region           = var.region
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

#  stage {
#    name = "Deploy"
#
#    action {
#      name            = "Deploy"
#      category        = "Deploy"
#      owner           = "AWS"
#      provider        = "S3"
#      input_artifacts = ["${var.prefix}-${var.service_name}-build"]
#      region          = var.region
#      version         = "1"
#
#      configuration = {
#        BucketName = var.web_app_bucket_name
#        Extract    = true
#      }
#    }
#  }
}