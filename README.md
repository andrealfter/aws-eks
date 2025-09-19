# AWS EKS Multi-Tier Architecture

This repository contains a production-ready AWS infrastructure deployment using Terraform, implementing a highly available, secure, and scalable multi-tier architecture on Amazon EKS.

## Architecture Overview

### Core Components

- **Amazon EKS**: Kubernetes orchestration platform with mixed On-Demand/Spot instances
- **Amazon Aurora PostgreSQL**: Primary relational database with Multi-AZ deployment
- **Amazon ElastiCache Redis**: In-memory caching layer with cluster mode enabled
- **Amazon S3**: Static content storage with lifecycle policies
- **Application Load Balancer**: Internet-facing load balancer with SSL termination
- **Amazon CloudFront**: Global CDN with AWS WAF integration
- **Amazon EFS**: Shared persistent storage for containers

### Security Features

- **Network Isolation**: Private subnets for compute and data layers
- **Encryption**: All data encrypted at rest and in transit
- **AWS Secrets Manager**: Automated credential rotation
- **AWS WAF**: Application-layer firewall protection
- **Security Groups**: Granular network access control
- **IAM Roles**: Fine-grained permission management

### High Availability

- **Multi-AZ Deployment**: Resources distributed across 3 availability zones
- **Auto-scaling**: Horizontal scaling for EKS nodes and pods
- **Database Replication**: Aurora with 2 read replicas
- **Cache Redundancy**: Redis with 3 shards and 2 replicas per shard
- **Backup Strategy**: Automated backups with point-in-time recovery

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0
- kubectl >= 1.29
- Helm >= 3.0

## Project Structure

```
aws-eks/
├── terraform/
│   ├── modules/
│   │   ├── vpc/           # VPC and networking configuration
│   │   ├── security/      # Security groups and NACLs
│   │   ├── iam/           # IAM roles and policies
│   │   ├── eks/           # EKS cluster and node groups
│   │   ├── rds/           # Aurora PostgreSQL database
│   │   ├── elasticache/   # Redis cluster configuration
│   │   └── s3/            # S3 buckets and policies
│   ├── environments/
│   │   └── production/    # Production environment configuration
│   ├── main.tf            # Main Terraform configuration
│   └── variables.tf       # Variable definitions
└── README.md
```

## Deployment Guide

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd aws-eks

# Navigate to production environment
cd terraform/environments/production
```

### 2. Configure Variables

Edit `terraform.tfvars` with your specific values:

```hcl
region          = "us-east-1"
project_name    = "your-project-name"
domain_name     = "your-domain.com"
alert_email     = "your-email@example.com"
```

### 3. Create Backend Resources

Before deploying, create the S3 bucket and DynamoDB table for Terraform state:

```bash
aws s3api create-bucket \
  --bucket terraform-state-aws-eks-app \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-aws-eks-app \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket terraform-state-aws-eks-app \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

### 5. Configure kubectl

After deployment, configure kubectl to connect to the EKS cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name aws-eks-app-production

# Verify connection
kubectl get nodes
```

### 6. Deploy AWS Load Balancer Controller

```bash
# Add the EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install the AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=aws-eks-app-production \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

## Post-Deployment Configuration

### 1. DNS Configuration

Update your Route 53 or DNS provider to point to the CloudFront distribution:

```bash
# Get CloudFront distribution domain
terraform output cloudfront_domain_name
```

### 2. SSL Certificate Validation

Ensure the ACM certificate is validated by adding the required DNS records.

### 3. Application Deployment

Deploy your application using Kubernetes manifests or Helm charts:

```bash
kubectl apply -f your-application-manifests/
```

### 4. Configure Auto-scaling

Deploy the Cluster Autoscaler:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

## Monitoring and Maintenance

### CloudWatch Dashboards

The infrastructure automatically creates CloudWatch alarms for:
- High CPU utilization
- Database connections
- Cache evictions
- Storage capacity

### Backup and Recovery

- **RDS**: Automated backups with 7-day retention
- **ElastiCache**: Daily snapshots with 5-day retention
- **S3**: Versioning enabled with lifecycle policies

### Cost Optimization

- **Spot Instances**: 70% of compute capacity on Spot
- **S3 Lifecycle**: Automatic transition to cheaper storage tiers
- **Reserved Capacity**: Consider purchasing Reserved Instances for stable workloads

## Security Best Practices

1. **Rotate Secrets Regularly**: Secrets Manager handles automatic rotation
2. **Update Security Groups**: Review and update security group rules periodically
3. **Patch Management**: Enable automatic minor version upgrades
4. **Audit Logging**: All API calls logged to CloudWatch
5. **Network Segmentation**: Use private subnets for sensitive resources

## Troubleshooting

### Common Issues

1. **EKS Node Connection Issues**
   ```bash
   kubectl get nodes
   kubectl describe node <node-name>
   ```

2. **Database Connectivity**
   ```bash
   kubectl run -it --rm debug --image=postgres:15 --restart=Never -- psql -h <aurora-endpoint>
   ```

3. **Redis Connection**
   ```bash
   kubectl run -it --rm redis-cli --image=redis:7 --restart=Never -- redis-cli -h <redis-endpoint>
   ```

## Cleanup

To destroy all resources:

```bash
terraform destroy -auto-approve
```

⚠️ **Warning**: This will delete all resources including databases and their backups. Ensure you have backed up any important data before proceeding.

## Support

For issues or questions, please open an issue in the repository or contact the infrastructure team.

## License

[Your License Here]