resource "aws_security_group" "ecs_instances" {
  name        = "${var.project}-${var.environment}-ecs_instances-sg"
  vpc_id      = var.vpc_id
  description = "Security Group for Public Access"

  ingress {
    description = "Security Group used to Application"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    tf_cluster_name = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = "ecs"
  image_id               = "ami-00285a945603a5def"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.ecs_instances.id]
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }

  user_data = base64encode(data.template_file.userdata.rendered)
}

resource "aws_autoscaling_group" "ecs-autoscaling_group" {
  name                = "ecs-autoscaling_group"
  vpc_zone_identifier = [var.ecs_subnets[0]]
#  desired_capacity    = 1
  max_size            = 3
  min_size            = 0

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
      }
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.project}-${var.environment}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 99
      instance_warmup_period    = 60
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

#  default_capacity_provider_strategy {
#    base              = 1
#    weight            = 100
#    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
#  }

  capacity_providers = compact([
    aws_ecs_capacity_provider.capacity_provider.name
    #  ,
    #    "FARGATE",
    #    "FARGATE_SPOT"
  ])
}
