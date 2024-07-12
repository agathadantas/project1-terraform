
resource "aws_codebuild_project" "webp_app_codebuild" {
  name          = var.codebuild_project_name
  build_timeout = "5"
  service_role  = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/${var.prefix}-${var.service_name}"
      stream_name = "${var.service_name}-logstream"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2
phases:
  pre_build:
    commands:
      - echo Installing npm packages...
      - npm install
  build:
    commands:
      - echo Build started on `date`
      - echo Building the web app...
      - npm run build:${var.environment}
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Send to S3 bucket
      - aws s3 sync ./dist s3://${var.s3_bucket_name}/
      - aws cloudfront create-invalidation --distribution-id ${var.cf_distribution_id} --paths "/*"
artifacts:
  files:
    - 'dist/**/*'
  discard-paths: yes
EOF
  }

  tags = {
    environment = var.environment
  }
}