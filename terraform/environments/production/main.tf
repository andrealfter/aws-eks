terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-aws-eks-app"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  name = "${var.project_name}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  region             = var.region
  tags               = local.tags
}

module "security" {
  source = "../../modules/security"

  name     = local.name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
  tags     = local.tags
}

module "iam" {
  source = "../../modules/iam"

  name                       = local.name
  region                     = var.region
  oidc_provider_arn          = module.eks.oidc_provider_arn
  create_alb_controller_role = true
  create_ebs_csi_driver_role = true
  create_efs_csi_driver_role = false
  tags                       = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name                           = local.name
  kubernetes_version             = var.kubernetes_version
  cluster_role_arn               = module.iam.eks_cluster_role_arn
  node_role_arn                  = module.iam.eks_node_role_name
  subnet_ids                     = module.vpc.private_subnet_ids
  node_subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id      = module.security.eks_cluster_security_group_id
  node_security_group_id         = module.security.eks_nodes_security_group_id
  cluster_endpoint_public_access = false
  node_instance_types            = var.node_instance_types
  node_group_min_size            = var.node_group_min_size
  node_group_max_size            = var.node_group_max_size
  node_group_desired_size        = var.node_group_desired_size
  enable_spot_instances          = true
  spot_instance_types            = var.spot_instance_types
  spot_node_group_min_size       = var.spot_node_group_min_size
  spot_node_group_max_size       = var.spot_node_group_max_size
  spot_node_group_desired_size   = var.spot_node_group_desired_size
  ebs_csi_driver_role_arn        = module.iam.ebs_csi_driver_role_arn
  enable_efs_csi_driver          = false
  environment                    = var.environment
  tags                           = local.tags
}



module "s3" {
  source = "../../modules/s3"

  name                 = local.name
  cors_allowed_origins = ["https://${var.domain_name}"]
  tags                 = local.tags
}



resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security.alb_security_group_id]
  subnets            = module.vpc.public_subnet_ids

  enable_deletion_protection       = true
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = module.s3.alb_logs_bucket_id
    enabled = true
  }

  tags = local.tags
}

resource "aws_lb_target_group" "main" {
  name                 = "${local.name}-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = local.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/application/${local.name}"
  retention_in_days = 30

  tags = local.tags
}

resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"

  tags = local.tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
