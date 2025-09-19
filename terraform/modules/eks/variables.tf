variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the EKS nodes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "List of subnet IDs for the EKS nodes"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  type        = string
}

variable "node_security_group_id" {
  description = "Security group ID for the EKS nodes"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain EKS cluster logs"
  type        = number
  default     = 30
}

variable "node_instance_types" {
  description = "List of instance types for the EKS nodes"
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 20
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 100
}

variable "ec2_ssh_key" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "ssh_access_security_group_ids" {
  description = "Security group IDs allowed SSH access to nodes"
  type        = list(string)
  default     = []
}

variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = true
}

variable "spot_instance_types" {
  description = "List of instance types for spot nodes"
  type        = list(string)
  default     = ["m6i.large", "m6i.xlarge", "m6a.large", "m6a.xlarge"]
}

variable "spot_node_group_min_size" {
  description = "Minimum size of the spot node group"
  type        = number
  default     = 0
}

variable "spot_node_group_max_size" {
  description = "Maximum size of the spot node group"
  type        = number
  default     = 10
}

variable "spot_node_group_desired_size" {
  description = "Desired size of the spot node group"
  type        = number
  default     = 3
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI addon"
  type        = string
  default     = null
}

variable "vpc_cni_role_arn" {
  description = "IAM role ARN for the VPC CNI addon"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the CoreDNS addon"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy addon"
  type        = string
  default     = null
}

variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver addon"
  type        = string
  default     = null
}

variable "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for the EBS CSI driver"
  type        = string
  default     = null
}

variable "enable_efs_csi_driver" {
  description = "Enable EFS CSI driver addon"
  type        = bool
  default     = true
}

variable "efs_csi_driver_version" {
  description = "Version of the EFS CSI driver addon"
  type        = string
  default     = null
}

variable "efs_csi_driver_role_arn" {
  description = "IAM role ARN for the EFS CSI driver"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
