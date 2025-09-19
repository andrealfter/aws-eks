output "cluster_id" {
  value = aws_rds_cluster.aurora.id
}

output "cluster_arn" {
  value = aws_rds_cluster.aurora.arn
}

output "cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_port" {
  value = aws_rds_cluster.aurora.port
}

output "database_name" {
  value = aws_rds_cluster.aurora.database_name
}

output "master_username" {
  value     = aws_rds_cluster.aurora.master_username
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.aurora_master.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.aurora_master.name
}

output "proxy_endpoint" {
  value = var.enable_proxy ? aws_db_proxy.aurora[0].endpoint : null
}

output "proxy_arn" {
  value = var.enable_proxy ? aws_db_proxy.aurora[0].arn : null
}

output "kms_key_id" {
  value = aws_kms_key.aurora.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.aurora.arn
}

output "security_group_id" {
  value = var.security_group_id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.aurora.name
}
