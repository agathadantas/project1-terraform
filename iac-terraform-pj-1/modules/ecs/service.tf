resource "aws_ecs_service" "user_service" {
  name            = "user-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.user_service.arn
  desired_count   = 1

#  capacity_provider_strategy {
#    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
#    weight = 1
#  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = var.user-service_tg_arn
    container_name   = "user-service"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = var.user-service-int_tg_arn
    container_name   = "user-service"
    container_port   = 80
  }
}

resource "aws_ecs_service" "appointment_service" {
  name            = "appointment-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.appointment_service.arn
  desired_count   = 1

#  capacity_provider_strategy {
#    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
#    weight = 1
#  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = var.appointment-service_tg_arn
    container_name   = "appointment-service"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = var.appointment-service-int_tg_arn
    container_name   = "appointment-service"
    container_port   = 80
  }
}

resource "aws_ecs_service" "notification_service" {
  name            = "notification-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.notification_service.arn
  desired_count   = 1

#  capacity_provider_strategy {
#    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
#    weight = 1
#  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = var.notification-service_tg_arn
    container_name   = "notification-service"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = var.notification-service-int_tg_arn
    container_name   = "notification-service"
    container_port   = 80
  }
}