
resource "aws_codebuild_project" "codebuild" {
  name          = "codebuild-${var.service_name}"
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
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.codebuild_image_repo_name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
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
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - IMAGE_TAG="snapshot-$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - IMAGE_NAME=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
  build:
    commands:
      - cd ${var.codebuild_build_path}
      - echo Build started on `date`
      - echo Running mvn clean install;
      - chmod +x mvnw
      - ./mvnw clean install -DskipTests
      - echo Building the Docker image...
      - aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 315120513061.dkr.ecr.eu-west-1.amazonaws.com
      - docker build -t $IMAGE_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - echo Pushing $IMAGE_NAME:$IMAGE_TAG
      - docker push $IMAGE_NAME:$IMAGE_TAG
      - echo Pushing $IMAGE_NAME:latest
      - docker push $IMAGE_NAME:latest
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/file-reference.html#pipelines-create-image-definitions
      - IMAGE_DIGEST=$(docker inspect $IMAGE_NAME:$IMAGE_TAG --format='{{index .RepoDigests}}' | tr -d '[]')
      - printf "[{\"name\":\"${var.service_name}\",\"imageUri\":\"$IMAGE_DIGEST\"}]" > imagedefinitions.json
artifacts:
  files:
    - ${var.codebuild_build_path}/imagedefinitions.json
  discard-paths: yes
EOF
  }

  tags = {
    environment = var.environment
  }
}