variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  type        = string
  default     = ""
}

variable "create_alb_controller_role" {
  description = "Whether to create IAM role for ALB controller"
  type        = bool
  default     = false
}

variable "create_ebs_csi_driver_role" {
  description = "Whether to create IAM role for EBS CSI driver"
  type        = bool
  default     = false
}

variable "create_efs_csi_driver_role" {
  description = "Whether to create IAM role for EFS CSI driver"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
