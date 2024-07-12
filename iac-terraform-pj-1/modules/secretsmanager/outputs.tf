output "secret_value" {
  value = data.aws_secretsmanager_secret_version.this.secret_string
}

output "db_secret_arn" {
  value = data.aws_secretsmanager_secret_version.this.arn
}

output "cognito_secret_arn" {
  value = data.aws_secretsmanager_secret_version.cognito.arn
}

output "email_secret_arn" {
  value = data.aws_secretsmanager_secret_version.email.arn
}

output "knok_secret_arn" {
  value = data.aws_secretsmanager_secret_version.knok.arn
}