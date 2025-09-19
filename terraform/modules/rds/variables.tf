variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of subnet IDs for database"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "instance_class" {
  description = "Instance class for Aurora writer"
  type        = string
  default     = "db.r6g.large"
}

variable "reader_instance_class" {
  description = "Instance class for Aurora readers"
  type        = string
  default     = ""
}

variable "reader_count" {
  description = "Number of reader instances"
  type        = number
  default     = 2
}

variable "serverless_min_capacity" {
  description = "Minimum capacity for Aurora Serverless v2"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "Maximum capacity for Aurora Serverless v2"
  type        = number
  default     = 16
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "enhanced_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "ARN of the IAM role for enhanced monitoring"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "enable_proxy" {
  description = "Enable RDS Proxy"
  type        = bool
  default     = true
}

variable "proxy_max_connections_percent" {
  description = "Maximum connections percent for RDS Proxy"
  type        = number
  default     = 100
}

variable "proxy_max_idle_connections_percent" {
  description = "Maximum idle connections percent for RDS Proxy"
  type        = number
  default     = 50
}

variable "proxy_connection_borrow_timeout" {
  description = "Connection borrow timeout for RDS Proxy"
  type        = number
  default     = 120
}

variable "proxy_idle_client_timeout" {
  description = "Idle client timeout for RDS Proxy"
  type        = number
  default     = 1800
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
