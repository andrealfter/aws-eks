output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "eks_cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "aurora_cluster_endpoint" {
  value = module.rds.cluster_endpoint
}

output "aurora_reader_endpoint" {
  value = module.rds.cluster_reader_endpoint
}

output "aurora_secret_arn" {
  value = module.rds.secret_arn
}

output "redis_configuration_endpoint" {
  value = module.elasticache.configuration_endpoint
}

output "redis_secret_arn" {
  value = module.elasticache.secret_arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}

output "static_content_bucket" {
  value = module.s3.static_content_bucket_id
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "kubectl_config" {
  value = <<-EOT
    aws eks update-kubeconfig \
      --region ${var.region} \
      --name ${module.eks.cluster_name}
  EOT
}
