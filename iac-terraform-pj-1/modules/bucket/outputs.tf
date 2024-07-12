output "bucket_name" {
  value = aws_s3_bucket.bucket_s3.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket_s3.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket_s3.id
}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.frontend_distribution.id
}

output "remote_state_bucket" {
  value = aws_s3_bucket.remote_state.bucket
}

output "remote_state_arn" {
  value = aws_s3_bucket.remote_state.arn
}