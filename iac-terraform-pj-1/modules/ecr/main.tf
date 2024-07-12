#user-service
resource "aws_ecr_repository" "user_service" {
  name                 = "pj-cd-acloud-${var.project}-${var.environment}-user-service-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-user-service-ecr"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_ecr_lifecycle_policy" "user_service_ecr_lifecycle" {
  repository = aws_ecr_repository.user_service.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

#appointment-service
resource "aws_ecr_repository" "appointment_service" {
  name                 = "pj-cd-acloud-${var.project}-${var.environment}-appointment-service-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-appointment-service-ecr"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_ecr_lifecycle_policy" "appointment_service_ecr_lifecycle" {
  repository = aws_ecr_repository.appointment_service.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

#notification-service
resource "aws_ecr_repository" "notification_service" {
  name                 = "pj-cd-acloud-${var.project}-${var.environment}-notification-service-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-notification-service-ecr"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_ecr_lifecycle_policy" "notification_service_ecr_lifecycle" {
  repository = aws_ecr_repository.notification_service.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}