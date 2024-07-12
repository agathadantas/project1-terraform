# --- database/main.tf ---
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "rds" {
  policy_id = "key-policy-rds"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "rds" {
  description = "RDS KEY"
  enable_key_rotation = "true"
  policy              = data.aws_iam_policy_document.rds.json
}


resource "aws_db_instance" "postgresql" {
  identifier              = "pj-cd-acloud-${var.project}-${var.environment}-rds-postgresql"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocate_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  username                = var.db_user
  password                = var.db_password
  db_name                 = var.db_name
  db_subnet_group_name    = var.db_subnet_group_name[0]
  multi_az                = var.db_multi_az
  skip_final_snapshot     = var.db_skip_final_snapshot
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retention_period = var.db_backup
  kms_key_id              = aws_kms_key.rds.arn
  storage_encrypted       = var.db_storage_encrypted

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-rds-postgresql"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_db_instance" "postgresql_replica" {
  count = var.use_replica ? 1 : 0
  replicate_source_db        = aws_db_instance.postgresql.identifier
  auto_minor_version_upgrade = false
  backup_retention_period    = var.db_backup
  identifier                 = "pj-cd-acloud-${var.project}-${var.environment}-rds-postgresql-replica"
  instance_class             = var.db_instance_class
  kms_key_id                 = aws_kms_key.rds.arn
  multi_az                   = var.db_multi_az
  skip_final_snapshot        = var.db_skip_final_snapshot
  storage_encrypted          = var.db_storage_encrypted

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-rds-postgresql-replica"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "pj-cd-acloud-${var.project}-${var.environment}-rds-sg"
  vpc_id      = var.vpc_id
  description = "RDS Security Group"

  ingress {
    description      = "ingress from vpc"
    protocol         = "tcp"
    from_port        = 5432
    to_port          = 5432
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