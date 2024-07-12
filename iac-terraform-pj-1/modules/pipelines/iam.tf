data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.prefix}-${var.codepipeline_role_name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values   = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
      var.web_app_bucket_arn,
      "${var.web_app_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = ["arn:aws:iam::${var.codecommit_account}:role/CodeCommit_crossAccount"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "ecr:DescribeImages",
    ]

    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.codepipeline.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecs:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.prefix}-${var.codepipeline_role_policy_name}"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codepipeline_role.name
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.prefix}-${var.codebuild_role_name}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_policy_doc" {
  statement {
    effect  = "Allow"
    sid     = "CloudWatchLogsPolicy"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    sid     = "S3GetObjectPolicy"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    sid     = "S3PutObjectPolicy"
    actions = [
      "s3:PutObject",
    ]
    resources = ["*"]

  }

  statement {
    effect  = "Allow"
    sid     = "S3BucketIdentity"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    sid     = "cloudfrontInvalidation"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_role.name
  name   = "${var.prefix}-${var.codebuild_role_policy_name}"
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name               = "${var.prefix}-${var.eventbridge_role_name}"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

data "aws_iam_policy_document" "eventbridge_policy_doc" {
  statement {
    effect  = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution",
    ]

    resources = [
      module.notification-service.pipeline_arn,
      module.appointment-service.pipeline_arn,
      module.user-service.pipeline_arn,
      module.web-app.web_app_pipeline_arn
    ]
  }
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name   = "${var.prefix}-${var.eventbridge_role_policy_name}"
  role   = aws_iam_role.eventbridge_role.name
  policy = data.aws_iam_policy_document.eventbridge_policy_doc.json
}