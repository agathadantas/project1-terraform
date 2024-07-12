# --- container/main.tf ---
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "pj-cd-acloud-${var.project}-${var.environment}-ecs-cluster"

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-ecs-cluster"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "pj-cd-acloud-${var.project}-${var.environment}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-ecsTaskRole"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_iam_policy" "rds_policy" {
  name        = "pj-cd-acloud-${var.project}-${var.environment}-policy-rds"
  description = "Policy that allows access to RDS: PostgreSQL"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "rds:CreateTable",
               "rds:UpdateTimeToLive",
               "rds:PutItem",
               "rds:DescribeTable",
               "rds:ListTables",
               "rds:DeleteItem",
               "rds:GetItem",
               "rds:Scan",
               "rds:Query",
               "rds:UpdateItem",
               "rds:UpdateTable"
           ],
           "Resource": "*"
       }
   ]
}
EOF
  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-policy-rds"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "pj-cd-acloud-${var.project}-${var.environment}-policy-ecs"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-policy-ecs"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment_secretmanger" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment_cloudwatch" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_security_group" "ecs_sg" {
  name        = "pj-cd-acloud-${var.project}-${var.environment}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS Cluster Security Group"

  ingress {
    description      = "Security Group used to ECS Cluster"
    protocol         = "tcp"
    from_port        = var.ecs_container_port
    to_port          = var.ecs_container_port
    cidr_blocks      = [var.vpc_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}