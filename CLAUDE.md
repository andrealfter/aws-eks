# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform-based AWS infrastructure project that deploys a production-ready EKS (Elastic Kubernetes Service) cluster with supporting infrastructure. The project uses a modular Terraform approach with reusable components.

## Essential Commands

```bash
# Initialize Terraform (required after any module changes)
make init

# Plan infrastructure changes
make plan

# Apply infrastructure changes
make apply

# Destroy infrastructure (use with caution)
make destroy

# Configure kubectl to connect to EKS cluster
make kubeconfig

# Format Terraform files
make fmt

# Validate Terraform configuration
make validate

# Show current infrastructure outputs
make output

# Deploy essential Kubernetes components after cluster creation
make deploy-alb-controller      # AWS Load Balancer Controller
make deploy-metrics-server       # Metrics for HPA
make deploy-cluster-autoscaler   # Node autoscaling
```

## Architecture & Module Structure

### Active Modules (in terraform/modules/)
- **vpc**: Creates VPC with public/private/database subnets across 3 AZs, NAT gateways, and VPC endpoints
- **security**: Defines all security groups for ALB, EKS cluster, nodes, and other services
- **iam**: Creates IAM roles for EKS cluster, nodes, and service accounts (IRSA)
- **eks**: Deploys EKS cluster with mixed On-Demand/Spot node groups and essential add-ons
- **s3**: Creates S3 buckets for static content, ALB logs, CloudFront logs, and backups

### Module Dependencies
```
vpc → security → iam → eks → s3
```
- VPC must be created first (networking foundation)
- Security groups depend on VPC
- IAM roles are referenced by EKS
- EKS needs VPC, security groups, and IAM roles
- S3 can be created independently but uses common tags

### Environment Configuration
- Main environment: `terraform/environments/production/`
- Variables are defined in `terraform/environments/production/variables.tf`
- Create `terraform.tfvars` from `terraform.tfvars.example` for deployment

## Key Architecture Decisions

### State Management
- Terraform state is stored in S3 with DynamoDB locking
- Backend configuration in `terraform/environments/production/main.tf`
- S3 bucket: `terraform-state-aws-eks-app`
- DynamoDB table: `terraform-state-lock`

### EKS Configuration
- Kubernetes version: 1.29
- Node groups: Mixed On-Demand (70%) and Spot (30%) instances
- Instance types: m6i.large, m6i.xlarge
- Add-ons: VPC CNI, CoreDNS, kube-proxy, EBS CSI Driver
- Private cluster endpoint (not publicly accessible)

### Networking
- VPC CIDR: 10.0.0.0/16
- 3 Availability Zones for high availability
- Private subnets for EKS nodes
- Public subnets for ALB
- Database subnets (reserved for future use)
- NAT Gateways in each AZ for outbound internet access

### Security
- All data encrypted at rest using KMS
- Security groups follow least privilege principle
- VPC endpoints for AWS services (S3, ECR, Secrets Manager)
- Private subnets for compute resources

## Common Issues & Solutions

### Terraform Init Fails
- Ensure AWS credentials are configured: `aws configure`
- Verify S3 backend bucket exists
- Check DynamoDB table for state locking exists

### EKS Node Connection Issues
- Nodes need proper IAM roles (handled by iam module)
- Security groups must allow communication between nodes and control plane
- User data script in `terraform/modules/eks/user_data.sh` bootstraps nodes

### Deprecation Warnings
- EKS addon `resolve_conflicts` → use `resolve_conflicts_on_update`
- S3 lifecycle rules require `filter {}` blocks

## Module Customization Notes

### Removed Modules
The following modules have been deleted from the codebase:
- **rds**: Aurora PostgreSQL setup (DELETED)
- **elasticache**: Redis cluster configuration (DELETED)

### Note on EFS Module
- **efs**: Elastic File System module still exists in `terraform/modules/efs/` but is NOT used
- This module needs to be manually deleted: `rm -rf terraform/modules/efs`
- It has been removed from all production configurations

### Cost Optimization
- Spot instances configured for 30% of compute capacity
- S3 lifecycle policies transition objects to cheaper storage tiers
- Development/staging environments can use smaller instance types

## Development Workflow

1. Make changes to relevant Terraform modules
2. Run `make fmt` to format code
3. Run `make validate` to check syntax
4. Run `make plan` to review changes
5. Run `make apply` after review
6. Test connectivity with `make test-connectivity`
7. Configure kubectl with `make kubeconfig`

## Important File Locations

- Main environment config: `terraform/environments/production/main.tf`
- Variable definitions: `terraform/environments/production/variables.tf`
- Module implementations: `terraform/modules/*/main.tf`
- Makefile with all commands: `Makefile` (root directory)