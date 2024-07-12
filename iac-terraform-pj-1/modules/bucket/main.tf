resource "aws_s3_bucket" "bucket_s3" {
  bucket = "pj-cd-acloud-${var.project}-${var.environment}-s3"

#  tags = {
#    Name        = "pj-cd-acloud-${var.project}-${var.environment}-s3"
#    Entity      = "pj"
#    Unit        = "cd"
#    Team        = "acloud"
#    Project     = var.project
#    Environment = var.environment
#    Region      = var.region
#    Repository  = var.repository
#  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_permission" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]

  bucket = aws_s3_bucket.bucket_s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "frontend_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket_s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
  statement {
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.bucket_s3.arn,
      "${aws_s3_bucket.bucket_s3.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [var.codebuild_role]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.bucket_s3.id
  policy = data.aws_iam_policy_document.frontend_s3_policy.json
}

#cdn
resource "aws_s3_bucket" "cdn" {
  bucket = "pj-cd-acloud-${var.project}-${var.environment}-cdn"
}

#resource "aws_s3_bucket_acl" "cdn_permission" {
#  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]
#
#  bucket = aws_s3_bucket.cdn.id
#  acl    = "private"
#}

resource "aws_s3_bucket_ownership_controls" "cdn_ownership" {
  bucket = aws_s3_bucket.cdn.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "cdn_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cdn.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = aws_s3_bucket.cdn.id
  policy = data.aws_iam_policy_document.cdn_s3_policy.json
}

data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "remote_state" {
  bucket = "tfstate-${data.aws_caller_identity.current.account_id}"

  versioning {
    enabled = true
  }
}
