variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-eks-app"
}

variable "domain_name" {
  description = "Primary domain name for the application"
  type        = string
  default     = "example.com"
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = "alerts@example.com"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Instance types for EKS nodes"
  type        = list(string)
  default     = ["m6i.large", "m6i.xlarge"]
}

variable "node_group_min_size" {
  description = "Minimum size of node group"
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "Maximum size of node group"
  type        = number
  default     = 20
}

variable "node_group_desired_size" {
  description = "Desired size of node group"
  type        = number
  default     = 6
}

variable "spot_instance_types" {
  description = "Instance types for spot nodes"
  type        = list(string)
  default     = ["m6i.large", "m6i.xlarge", "m6a.large", "m6a.xlarge"]
}

variable "spot_node_group_min_size" {
  description = "Minimum size of spot node group"
  type        = number
  default     = 0
}

variable "spot_node_group_max_size" {
  description = "Maximum size of spot node group"
  type        = number
  default     = 10
}

variable "spot_node_group_desired_size" {
  description = "Desired size of spot node group"
  type        = number
  default     = 3
}



variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
