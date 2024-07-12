resource "aws_secretsmanager_secret" "this" {
  name                    = "pj-cd-acloud-${var.project}-${var.environment}-database-secret"
  recovery_window_in_days = 0

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-secretsmanager"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "xxxxxxxxxx"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.this.result
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  depends_on = [aws_secretsmanager_secret_version.this]
}

# cognito
resource "aws_secretsmanager_secret" "cognito" {
  name                    = "pj-cd-acloud-${var.project}-${var.environment}-cognito-secret"
  recovery_window_in_days = 0

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-cognito-secret"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_secretsmanager_secret_version" "cognito" {
  secret_id     = aws_secretsmanager_secret.cognito.id
  secret_string = "{\"COGNITO_USER_POOL_IDS\": \"\",\"COGNITO_ISSUER_URIS\": \"\",\"COGNITO_USER_INFO_URIS\": \"\",\"COGNITO_CLIENT_IDS\": \"\",\"COGNITO_ACCESS_KEY\": \"\",\"COGNITO_ACCESS_SECRET_KEY\": \"\",\"AWS_COGNITO_KEY_ARN\": \" \",\"AWS_SECRET_ACCESS_KEY\": \" \",\"AWS_ACCESS_KEY_ID\": \" \"}"
}

data "aws_secretsmanager_secret_version" "cognito" {
  secret_id = aws_secretsmanager_secret.cognito.id
  depends_on = [aws_secretsmanager_secret_version.cognito]
}

# email
resource "aws_secretsmanager_secret" "email" {
  name                    = "pj-cd-acloud-${var.project}-${var.environment}-email-secret"
  recovery_window_in_days = 0

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-email-secret"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_secretsmanager_secret_version" "email" {
  secret_id     = aws_secretsmanager_secret.email.id
  secret_string = "{\"MAIL_HOST\": \"\",\"MAIL_PORT\": \"\",\"MAIL_USERNAME\": \"\",\"MAIL_PASSWORD\": \"\",\"MAIL_FROM\": \"\"}"
}

data "aws_secretsmanager_secret_version" "email" {
  secret_id = aws_secretsmanager_secret.email.id
  depends_on = [aws_secretsmanager_secret_version.email]
}

# knok
resource "aws_secretsmanager_secret" "knok" {
  name                    = "pj-cd-acloud-${var.project}-${var.environment}-knok-secret"
  recovery_window_in_days = 0

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-knok-secret"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_secretsmanager_secret_version" "knok" {
  secret_id     = aws_secretsmanager_secret.knok.id
  secret_string = "{\"KNOK_SERVICE_URL\": \"\",\"KNOK_API_KEY\": \"\",\"KNOK_API_SECRET\": \"\",\"PARTNER_CLIENT_ID\": \"\",\"PARTNER_CLIENT_SECRET\": \"\"}"
}

data "aws_secretsmanager_secret_version" "knok" {
  secret_id = aws_secretsmanager_secret.knok.id
  depends_on = [aws_secretsmanager_secret_version.knok]
}