resource "aws_security_group" "lb_sg" {
  name        = "pj-cd-acloud-${var.project}-${var.environment}-lb-sg"
  vpc_id      = var.vpc_cidr
  description = "Security Group for Public Access"

  ingress {
    description = "Security Group used to Application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Security Group used to Application"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "loadbalancer" {
  name               = "pj-cd-acloud-${var.project}-${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets.*

  enable_deletion_protection = false

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-lb"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# user service
resource "aws_lb_target_group" "user-service" {
  name        = "${var.project}-${var.environment}-user-service-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 4
    interval            = 50
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/users/health-api/status"
    unhealthy_threshold = 4
  }

  tags = {
    Name        = "${var.project}-${var.environment}-user-service-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# appointment service
resource "aws_lb_target_group" "appointment-service" {
  name        = "${var.project}-${var.environment}-appointment-srv-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"


  health_check {
    healthy_threshold   = 4
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/appointments/health-api/status"
    unhealthy_threshold = 4
  }

  tags = {
    Name        = "${var.project}-${var.environment}-appointment-srv-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# notification service
resource "aws_lb_target_group" "notification-service" {
  name        = "${var.environment}-notification-srv-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/email/health-api/status"
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project}-${var.environment}-notification-srv-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.eu-west-1_certificate


  default_action {
    target_group_arn = aws_lb_target_group.user-service.arn
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }


  tags = {
    Name        = "${var.project}-${var.environment}-user-service-http"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}


resource "aws_lb_listener_rule" "service-api_routing-internal" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 10

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
  condition {
    path_pattern {
      values = ["/v1/users/service-api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "appointment-service-api_routing-internal" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 20

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = ["/v1/appointments/service-api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "user-service_routing" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user-service.arn
  }

  condition {
    path_pattern {
      values = ["/v1/users/*","/v1/users"]
    }
  }
}

resource "aws_lb_listener_rule" "appointment-service_routing" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appointment-service.arn
  }

  condition {
    path_pattern {
      values = ["/v1/appointments/*","/v1/appointments"]
    }
  }
}

resource "aws_lb_listener_rule" "notification-service_routing" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notification-service.arn
  }

  condition {
    path_pattern {
      values = ["/v1/email/*"]
    }
  }
}

# Internal Load Balancer Resources
resource "aws_lb" "loadbalancer-internal" {
  name               = "pj-cd-acloud-${var.project}-${var.environment}-int"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets.*

  enable_deletion_protection = false

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-lb-internal"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# Private internal API 
resource "aws_lb_target_group" "service-api-int" {
  name        = "${var.environment}-service-api-int-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/service-api/health-api/status"
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.environment}-service-api-int-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_lb_target_group" "appointment-service-api-int" {
  name        = "${var.environment}-appoint-api-int-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/appointment-srv-api/health-api/status"
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.environment}-appointment-api-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# internal user service
resource "aws_lb_target_group" "user-service-int" {
  name        = "${var.environment}-user-service-int-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 4
    interval            = 50
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/users/health-api/status"
    unhealthy_threshold = 4
  }

  tags = {
    Name        = "${var.environment}-user-service-int-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# internal appointment service
resource "aws_lb_target_group" "appointment-service-int" {
  name        = "${var.project}-${var.environment}-appointment-int-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"


  health_check {
    healthy_threshold   = 4
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/appointments/health-api/status"
    unhealthy_threshold = 4
  }

  tags = {
    Name        = "${var.project}-${var.environment}-appointment-int-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

# internal notification service
resource "aws_lb_target_group" "notification-service-int" {
  name        = "${var.environment}-notification-int-tg"
  port        = var.tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_cidr
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    path                = "/v1/email/health-api/status"
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.environment}-notification-int-tg"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_lb_listener" "http-listener-internal" {
  load_balancer_arn = aws_lb.loadbalancer-internal.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.eu-west-1_certificate


  default_action {
    target_group_arn = aws_lb_target_group.user-service-int.arn
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-user-service-http-internal"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_lb_listener_rule" "user-service_routing-internal" {
  listener_arn = aws_lb_listener.http-listener-internal.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user-service-int.arn
  }

  condition {
    path_pattern {
      values = ["/v1/users/*","/v1/users"]
    }
  }
}

resource "aws_lb_listener_rule" "appointment-service_routing-internal" {
  listener_arn = aws_lb_listener.http-listener-internal.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appointment-service-int.arn
  }

  condition {
    path_pattern {
      values = ["/v1/appointments/*","/v1/appointments"]
    }
  }
}

resource "aws_lb_listener_rule" "notification-service_routing-internal" {
  listener_arn = aws_lb_listener.http-listener-internal.arn
  priority     = 60

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notification-service-int.arn
  }

  condition {
    path_pattern {
      values = ["/v1/email/*"]
    }
  }
}