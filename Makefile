.PHONY: help init plan apply destroy fmt validate clean kubeconfig

ENVIRONMENT ?= production
TERRAFORM_DIR = terraform/environments/$(ENVIRONMENT)

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "Initializing Terraform for $(ENVIRONMENT) environment..."
	@cd $(TERRAFORM_DIR) && terraform init

plan: ## Run Terraform plan
	@echo "Running Terraform plan for $(ENVIRONMENT) environment..."
	@cd $(TERRAFORM_DIR) && terraform plan -out=tfplan

apply: ## Apply Terraform configuration
	@echo "Applying Terraform configuration for $(ENVIRONMENT) environment..."
	@cd $(TERRAFORM_DIR) && terraform apply -auto-approve

destroy: ## Destroy all infrastructure
	@echo "⚠️  WARNING: This will destroy all infrastructure in $(ENVIRONMENT) environment!"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive terraform/

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@cd $(TERRAFORM_DIR) && terraform validate

clean: ## Clean up Terraform files
	@echo "Cleaning up Terraform files..."
	@find terraform -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find terraform -name "*.tfstate*" -delete 2>/dev/null || true
	@find terraform -name "*.tfplan" -delete 2>/dev/null || true
	@find terraform -name ".terraform.lock.hcl" -delete 2>/dev/null || true

kubeconfig: ## Configure kubectl for EKS cluster
	@echo "Configuring kubectl for EKS cluster..."
	@aws eks update-kubeconfig --region us-east-1 --name aws-eks-app-$(ENVIRONMENT)

output: ## Show Terraform outputs
	@cd $(TERRAFORM_DIR) && terraform output

backup-state: ## Backup Terraform state to local file
	@echo "Backing up Terraform state..."
	@mkdir -p backups
	@cd $(TERRAFORM_DIR) && terraform state pull > ../../backups/terraform-state-$(ENVIRONMENT)-$$(date +%Y%m%d-%H%M%S).json
	@echo "State backed up to backups/"

test-connectivity: ## Test connectivity to infrastructure components
	@echo "Testing EKS connectivity..."
	@kubectl get nodes || echo "❌ Failed to connect to EKS"
	@echo "\nTesting RDS connectivity..."
	@cd $(TERRAFORM_DIR) && terraform output -raw aurora_cluster_endpoint || echo "❌ Failed to get RDS endpoint"
	@echo "\nTesting Redis connectivity..."
	@cd $(TERRAFORM_DIR) && terraform output -raw redis_configuration_endpoint || echo "❌ Failed to get Redis endpoint"

install-tools: ## Install required tools
	@echo "Checking and installing required tools..."
	@which terraform > /dev/null || (echo "Installing Terraform..." && brew install terraform)
	@which kubectl > /dev/null || (echo "Installing kubectl..." && brew install kubectl)
	@which helm > /dev/null || (echo "Installing Helm..." && brew install helm)
	@which aws > /dev/null || (echo "Installing AWS CLI..." && brew install awscli)
	@echo "✅ All tools installed"

deploy-alb-controller: ## Deploy AWS Load Balancer Controller
	@echo "Deploying AWS Load Balancer Controller..."
	@helm repo add eks https://aws.github.io/eks-charts || true
	@helm repo update
	@helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
		-n kube-system \
		--set clusterName=aws-eks-app-$(ENVIRONMENT) \
		--set serviceAccount.create=false \
		--set serviceAccount.name=aws-load-balancer-controller

deploy-metrics-server: ## Deploy Kubernetes Metrics Server
	@echo "Deploying Metrics Server..."
	@kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

deploy-cluster-autoscaler: ## Deploy Cluster Autoscaler
	@echo "Deploying Cluster Autoscaler..."
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
	@kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

cost-estimate: ## Estimate monthly AWS costs
	@echo "Estimating monthly costs for $(ENVIRONMENT) environment..."
	@cd $(TERRAFORM_DIR) && terraform plan -out=tfplan > /dev/null && \
		echo "\nEstimated monthly costs:" && \
		echo "- EKS Cluster: ~$$73/month" && \
		echo "- EC2 Instances (6x m6i.large): ~$$410/month" && \
		echo "- EC2 Spot Instances (3x m6i.large): ~$$60/month" && \
		echo "- Aurora PostgreSQL: ~$$350/month" && \
		echo "- ElastiCache Redis: ~$$450/month" && \
		echo "- NAT Gateways (3x): ~$$135/month" && \
		echo "- Load Balancer: ~$$25/month" && \
		echo "- CloudFront: ~$$50/month" && \
		echo "- Storage & Backups: ~$$100/month" && \
		echo "--------------------------------" && \
		echo "Total Estimated: ~$$1,653/month" && \
		echo "\nNote: Actual costs may vary based on usage"
