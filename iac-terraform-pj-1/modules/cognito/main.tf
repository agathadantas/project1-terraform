resource "aws_cognito_user_pool" "userpool_cognito_medical" {
  name                     = "pj-cd-acloud-${var.project}-${var.environment}-cognito-medical"
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-cognito_medical"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain_medical" {
  domain       = "${var.project}-${var.environment}-medical"
  user_pool_id = aws_cognito_user_pool.userpool_cognito_medical.id
}

resource "aws_cognito_user_pool_client" "user_pool_client_medical" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.userpool_cognito_medical.id
}

resource "aws_cognito_user_pool" "userpool_cognito_patient" {
  name                     = "pj-cd-acloud-${var.project}-${var.environment}-cognito-patient"
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-cognito-patient"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain_patient" {
  domain       = "${var.project}-${var.environment}-patient"
  user_pool_id = aws_cognito_user_pool.userpool_cognito_patient.id
}

resource "aws_cognito_user_pool_client" "user_pool_client_patient" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.userpool_cognito_patient.id
}