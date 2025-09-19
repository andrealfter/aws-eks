#!/bin/bash

# Git commit script for AWS EKS infrastructure changes

cd /Users/andre.alfter/Projects/aws-eks

# Add all changes including deletions
git add -A

# Create commit with descriptive message
git commit -m "Refactor: Streamline AWS EKS infrastructure and remove unused services

- Remove RDS, ElastiCache, and EFS modules (not needed)
- Fix all Terraform deprecation warnings and errors
- Update EKS addon configurations (resolve_conflicts_on_update)
- Fix S3 lifecycle configuration (add filter blocks)
- Clean up variables and outputs
- Update cost estimates (~$753/month, saved $900/month)
- Add comprehensive documentation (CLAUDE.md)
- Format all Terraform files
- Security improvements: private EKS endpoint, encrypted storage
- Cost optimization: Spot instances (30%), S3 lifecycle policies
- Update README and Makefile

BREAKING CHANGES:
- Removed Aurora PostgreSQL support
- Removed ElastiCache Redis support
- Removed EFS support
- These can be re-added if needed in the future

The infrastructure is now focused on core EKS functionality with:
- VPC with 3 AZ configuration
- EKS cluster with mixed On-Demand/Spot nodes
- S3 for storage
- Application Load Balancer
- Comprehensive security groups and IAM roles"

# Push to remote
git push origin main

echo "✅ Changes committed and pushed to remote repository"
