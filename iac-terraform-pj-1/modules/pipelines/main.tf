data "aws_caller_identity" "current" {}

module "user-service" {
  source                    = "./java"
  prefix                    = var.prefix
  region                    = var.region
  environment               = var.environment
  account_id                = var.account_id
  codepipeline_bucket_id    = aws_s3_bucket.codepipeline_bucket.id
  codepipeline_role_arn     = aws_iam_role.codepipeline_role.arn
  codebuild_role_arn        = aws_iam_role.codebuild_role.arn
  codebuild_image_repo_name = "pj-cd-acloud-company-${var.environment}-user-service-ecr"
  codebuild_build_path      = "user-service"
  ecs_service_name          = "user-service"
  eventbridge_role_arn      = aws_iam_role.eventbridge_role.arn
  source_branch             = var.source_branch
  ecs_cluster_name          = var.ecs_cluster_name
  kms_key_arn               = aws_kms_key.codepipeline.arn
  codecommit_account        = var.codecommit_account
  service_name              = "user-service"
  source_repository_name    = "company-be-user-service"
  target_group_name         = "user-service-target"
}

module "appointment-service" {
  source                    = "./java"
  prefix                    = var.prefix
  region                    = var.region
  environment               = var.environment
  account_id                = var.account_id
  codepipeline_bucket_id    = aws_s3_bucket.codepipeline_bucket.id
  codepipeline_role_arn     = aws_iam_role.codepipeline_role.arn
  codebuild_role_arn        = aws_iam_role.codebuild_role.arn
  codebuild_image_repo_name = "pj-cd-acloud-company-${var.environment}-appointment-service-ecr"
  ecs_service_name          = "appointment-service"
  eventbridge_role_arn      = aws_iam_role.eventbridge_role.arn
  source_branch             = var.source_branch
  ecs_cluster_name          = var.ecs_cluster_name
  kms_key_arn               = aws_kms_key.codepipeline.arn
  codecommit_account        = var.codecommit_account
  service_name              = "appointment-service"
  source_repository_name    = "company-be-appointment-service"
  target_group_name         = "appointment-service-target"
}

module "notification-service" {
  source                    = "./java"
  prefix                    = var.prefix
  region                    = var.region
  environment               = var.environment
  account_id                = var.account_id
  codepipeline_bucket_id    = aws_s3_bucket.codepipeline_bucket.id
  codepipeline_role_arn     = aws_iam_role.codepipeline_role.arn
  codebuild_role_arn        = aws_iam_role.codebuild_role.arn
  codebuild_image_repo_name = "pj-cd-acloud-company-${var.environment}-notification-service-ecr"
  ecs_service_name          = "notification-service"
  eventbridge_role_arn      = aws_iam_role.eventbridge_role.arn
  source_branch             = var.source_branch
  ecs_cluster_name          = var.ecs_cluster_name
  kms_key_arn               = aws_kms_key.codepipeline.arn
  codecommit_account        = var.codecommit_account
  service_name              = "notification-service"
  source_repository_name    = "company-be-email-service"
  target_group_name         = "notification-service-target"
}

module "web-app" {
  source                 = "./web-app/"
  prefix                 = var.prefix
  region                 = var.region
  environment            = var.environment
  codepipeline_bucket_id = aws_s3_bucket.codepipeline_bucket.id
  codepipeline_role_arn  = aws_iam_role.codepipeline_role.arn
  codebuild_role_arn     = aws_iam_role.codebuild_role.arn
  eventbridge_role_arn   = aws_iam_role.eventbridge_role.arn
  # codedeploy_role_arn = aws_iam_role.codedeploy_role.arn
  web_app_bucket_name    = var.web_app_bucket_name
  source_branch          = var.source_branch
  codecommit_account     = var.codecommit_account
  kms_key_arn            = aws_kms_key.codepipeline.arn
  source_repository_name = "company-fe-web"
  cf_distribution_id     = var.cf_distribution_id
  s3_bucket_name         = var.s3_bucket_name
}

resource "aws_kms_key" "codepipeline" {
  description             = "KMS codepipeline"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:*",
        ]

        Principal : { AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "kms:*",
        ]

        Principal : { AWS : "arn:aws:iam::${var.codecommit_account}:role/CodeCommit_crossAccount" },
        Effect   = "Allow"
        Resource = "*"
      },
      #      {
      #        Action = [
      #          "kms:*",
      #        ]
      #
      #        Principal : { AWS : "arn:aws:iam::${var.codecommit_account}:root" },
      #        Effect   = "Allow"
      #        Resource = "*"
      #      },
      {
        Action = [
          "kms:*",
        ]
        Principal : { AWS : aws_iam_role.codepipeline_role.arn },
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "kms:*",
        ]
        Principal : { AWS : aws_iam_role.codebuild_role.arn },
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.prefix}-${var.codepipeline_bucket_name}"

}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket_encription" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codepipeline.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket     = aws_s3_bucket.codepipeline_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_acl_ownership" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

data "aws_iam_policy_document" "codepipeline_bucket_policy" {
  statement {
    actions   = ["s3:Get*", "s3:Put*", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        #        "arn:aws:iam::${var.codecommit_account}:root",
        "arn:aws:iam::${var.codecommit_account}:role/CodeCommit_crossAccount",
        aws_iam_role.codepipeline_role.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "codepipeline_bucket_policy" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.codepipeline_bucket_policy.json
}
