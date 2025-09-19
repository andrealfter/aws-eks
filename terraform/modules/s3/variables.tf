variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "alb_logs_retention_days" {
  description = "ALB logs retention in days"
  type        = number
  default     = 30
}

variable "cloudfront_logs_retention_days" {
  description = "CloudFront logs retention in days"
  type        = number
  default     = 30
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
