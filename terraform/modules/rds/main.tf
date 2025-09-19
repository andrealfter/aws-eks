resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name}-aurora-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-subnet-group"
    }
  )
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${var.name}-aurora-cluster-params"
  family      = "aurora-postgresql15"
  description = "Aurora PostgreSQL cluster parameter group for ${var.name}"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pgaudit"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "aurora" {
  name        = "${var.name}-aurora-instance-params"
  family      = "aurora-postgresql15"
  description = "Aurora PostgreSQL instance parameter group for ${var.name}"

  parameter {
    name  = "log_temp_files"
    value = "0"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  tags = var.tags
}

resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora database encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-kms-key"
    }
  )
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.name}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

resource "random_password" "aurora_master" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "aurora_master" {
  name                    = "${var.name}-aurora-master-password"
  description             = "Master password for Aurora PostgreSQL cluster"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.aurora.id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "aurora_master" {
  secret_id = aws_secretsmanager_secret.aurora_master.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.aurora_master.result
    engine   = "aurora-postgresql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = aws_rds_cluster.aurora.port
    dbname   = var.database_name
  })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${var.name}-aurora-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  engine_mode                     = "provisioned"
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = random_password.aurora_master.result
  port                            = 5432

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name
  db_subnet_group_name             = aws_db_subnet_group.aurora.name
  vpc_security_group_ids           = [var.security_group_id]

  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.aurora.arn

  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  preferred_maintenance_window    = var.maintenance_window

  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.name}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  copy_tags_to_snapshot           = true
  apply_immediately               = var.apply_immediately

  serverlessv2_scaling_configuration {
    max_capacity = var.serverless_max_capacity
    min_capacity = var.serverless_min_capacity
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-cluster"
    }
  )

  lifecycle {
    ignore_changes = [master_password]
  }
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier                   = "${var.name}-aurora-writer"
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.instance_class
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  db_parameter_group_name      = aws_db_parameter_group.aurora.name

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? aws_kms_key.aurora.arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval          = var.enhanced_monitoring_interval
  monitoring_role_arn          = var.enhanced_monitoring_interval > 0 ? var.monitoring_role_arn : null

  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-writer"
      Type = "writer"
    }
  )
}

resource "aws_rds_cluster_instance" "aurora_reader" {
  count = var.reader_count

  identifier                   = "${var.name}-aurora-reader-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.reader_instance_class != "" ? var.reader_instance_class : var.instance_class
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  db_parameter_group_name      = aws_db_parameter_group.aurora.name

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? aws_kms_key.aurora.arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval          = var.enhanced_monitoring_interval
  monitoring_role_arn          = var.enhanced_monitoring_interval > 0 ? var.monitoring_role_arn : null

  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-reader-${count.index + 1}"
      Type = "reader"
    }
  )
}

resource "aws_db_proxy" "aurora" {
  count = var.enable_proxy ? 1 : 0

  name                   = "${var.name}-aurora-proxy"
  engine_family          = "POSTGRESQL"
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.aurora_master.arn
  }

  role_arn               = aws_iam_role.proxy[0].arn
  vpc_subnet_ids         = var.database_subnet_ids
  vpc_security_group_ids = [var.security_group_id]

  max_connections_percent        = var.proxy_max_connections_percent
  max_idle_connections_percent   = var.proxy_max_idle_connections_percent
  connection_borrow_timeout      = var.proxy_connection_borrow_timeout
  idle_client_timeout            = var.proxy_idle_client_timeout

  require_tls = true

  target {
    db_cluster_identifier = aws_rds_cluster.aurora.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-aurora-proxy"
    }
  )
}

resource "aws_iam_role" "proxy" {
  count = var.enable_proxy ? 1 : 0

  name = "${var.name}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "proxy" {
  count = var.enable_proxy ? 1 : 0

  name = "${var.name}-rds-proxy-policy"
  role = aws_iam_role.proxy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.aurora_master.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.aurora.arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "aurora_cpu" {
  alarm_name          = "${var.name}-aurora-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Aurora CPU utilization"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "aurora_connections" {
  alarm_name          = "${var.name}-aurora-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Aurora database connections"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "aurora_storage" {
  alarm_name          = "${var.name}-aurora-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeLocalStorage"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5368709120"
  alarm_description   = "This metric monitors Aurora free storage"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  tags = var.tags
}
