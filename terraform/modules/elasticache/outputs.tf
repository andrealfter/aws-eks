output "replication_group_id" {
  value = aws_elasticache_replication_group.redis.id
}

output "replication_group_arn" {
  value = aws_elasticache_replication_group.redis.arn
}

output "configuration_endpoint" {
  value = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "reader_endpoint" {
  value = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "port" {
  value = 6379
}

output "secret_arn" {
  value = aws_secretsmanager_secret.redis_auth.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.redis_auth.name
}

output "kms_key_id" {
  value = aws_kms_key.redis.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.redis.arn
}

output "security_group_id" {
  value = var.security_group_id
}

output "subnet_group_name" {
  value = aws_elasticache_subnet_group.redis.name
}
