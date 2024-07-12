resource "aws_ecs_task_definition" "user_service" {
  family                = "user-service"
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      name         = "user-service"
      image        = "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/pj-cd-acloud-company-${var.environment}-user-service-ecr:latest"
      cpu          = 0
      essential    = true

      healthCheck = {
        retries = 10
        command = [ "CMD-SHELL", "curl -f http://localhost/v1/users/health-api/status || exit 1" ]
        timeout: 5
        interval: 10
        startPeriod: 70
      }

      portMappings = [
        {
          name          = "user-service-80-tcp",
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "CORS_ALLOWED_ORIGINS",
          value = "*"
        },
        {
          name  = "DB_USERNAME",
          value = "company${var.environment}"
        },
        {
          name  = "DB_URL",
          value = "jdbc:postgresql://${var.db_url}/company${var.environment}db"
        },
        {
          name  = "FRONTEND_BASE_URL",
          value = "https://${var.domain}"
        },
        {
          name  = "SPRING_PROFILE_ACTIVE",
          value = var.environment
        },
      ]
      secrets = [
        {
          name      = "DB_PASSWORD",
          valueFrom = var.db_secret_arn
        },
        {
          name : "COGNITO_USER_POOL_IDS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_USER_POOL_IDS::"
        },
        {
          name : "COGNITO_ISSUER_URIS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_ISSUER_URIS::"
        },
        {
          name : "COGNITO_USER_INFO_URIS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_USER_INFO_URIS::"
        },
        {
          name : "COGNITO_CLIENT_IDS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_CLIENT_IDS::"
        },
        {
          name : "COGNITO_ACCESS_KEY",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_ACCESS_KEY::"
        },
        {
          name : "COGNITO_ACCESS_SECRET_KEY",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_ACCESS_SECRET_KEY::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/project-pt-user-service",
          awslogs-region        = "eu-west-1",
          awslogs-stream-prefix = "user-service"
        }
      }
    }
  ])
  cpu    = 512
  memory = 1024
}

resource "aws_ecs_task_definition" "notification_service" {
  family                = "notification-service"
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      name         = "notification-service"
      image        = "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/pj-cd-acloud-company-${var.environment}-notification-service-ecr:latest"
      cpu          = 0
      essential    = true

      healthCheck = {
        retries = 10
        command = [ "CMD-SHELL", "curl -f http://localhost/v1/email/health-api/status || exit 1" ]
        timeout: 5
        interval: 10
        startPeriod: 30
      }

      portMappings = [
        {
          name          = "notification-service-80-tcp",
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "CORS_ALLOWED_ORIGINS",
          value = "*"
        },
        {
          name  = "SPRING_PROFILE_ACTIVE",
          value = var.environment
        },
        {
          name  = "FRONTEND_BASE_URL",
          value = "https://${var.domain}"
        }
      ]
      secrets = [
        {
          name : "MAIL_HOST",
          valueFrom : "${var.email_secret_arn}:MAIL_HOST::"
        },
        {
          name : "MAIL_PORT",
          valueFrom : "${var.email_secret_arn}:MAIL_PORT::"
        },
        {
          name : "MAIL_USERNAME",
          valueFrom : "${var.email_secret_arn}:MAIL_USERNAME::"
        },
        {
          name : "MAIL_PASSWORD",
          valueFrom : "${var.email_secret_arn}:MAIL_PASSWORD::"
        },
        {
          name : "MAIL_FROM",
          valueFrom : "${var.email_secret_arn}:MAIL_FROM::"
        },
        {
          name : "AWS_ACCESS_KEY_ID",
          valueFrom : "${var.cognito_secret_arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name : "AWS_SECRET_ACCESS_KEY",
          valueFrom : "${var.cognito_secret_arn}:AWS_SECRET_ACCESS_KEY::"
        },
        {
          name : "AWS_COGNITO_KEY_ARN",
          valueFrom : "${var.cognito_secret_arn}:AWS_COGNITO_KEY_ARN::"
        }

      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/project-pt-notification-service",
          awslogs-region        = "eu-west-1",
          awslogs-stream-prefix = "notification-service"
        }
      }
    }
  ])
  cpu    = 512
  memory = 1024
}

resource "aws_ecs_task_definition" "appointment_service" {
  family                = "appointment-service"
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      name         = "appointment-service"
      image        = "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/pj-cd-acloud-company-${var.environment}-appointment-service-ecr:latest"
      cpu          = 0
      essential    = true

      healthCheck = {
        retries = 10
        command = [ "CMD-SHELL", "curl -f http://localhost/v1/appointments/health-api/status || exit 1" ]
        timeout: 5
        interval: 10
        startPeriod: 65
      }

      portMappings = [
        {
          name          = "appointment-service-80-tcp",
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "CORS_ALLOWED_ORIGINS",
          value = "*"
        },
        {
          name  = "DB_USERNAME",
          value = "company${var.environment}"
        },
        {
          name  = "DB_URL",
          value = "jdbc:postgresql://${var.db_url}/company${var.environment}db"
        },
        {
          name  = "USER_SERVICE_URL",
          value = "https://internal.${var.domain}"
        },
        {
          name  = "SPRING_PROFILE_ACTIVE",
          value = var.environment
        }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD",
          valueFrom = var.db_secret_arn
        },
        {
          name : "COGNITO_USER_POOL_IDS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_USER_POOL_IDS::"
        },
        {
          name : "COGNITO_ISSUER_URIS",
          valueFrom : "${var.cognito_secret_arn}:COGNITO_ISSUER_URIS::"
        },
        {
          name : "KNOK_SERVICE_URL",
          valueFrom : "${var.knok_secret_arn}:KNOK_SERVICE_URL::"
        },
        {
          name : "KNOK_API_KEY",
          valueFrom : "${var.knok_secret_arn}:KNOK_API_KEY::"
        },
        {
          name : "KNOK_API_SECRET",
          valueFrom : "${var.knok_secret_arn}:KNOK_API_SECRET::"
        },
        {
          name : "PARTNER_CLIENT_ID",
          valueFrom : "${var.knok_secret_arn}:PARTNER_CLIENT_ID::"
        },
        {
          name : "PARTNER_CLIENT_SECRET",
          valueFrom : "${var.knok_secret_arn}:PARTNER_CLIENT_SECRET::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/project-pt-appointment-service",
          awslogs-region        = "eu-west-1",
          awslogs-stream-prefix = "appointment-service"
        }
      }
    }
  ])
  cpu    = 512
  memory = 1024
}
