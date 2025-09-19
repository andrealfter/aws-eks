output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "nlb_security_group_id" {
  value = aws_security_group.nlb.id
}

output "eks_cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  value = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  value = aws_security_group.elasticache.id
}

output "efs_security_group_id" {
  value = aws_security_group.efs.id
}

output "documentdb_security_group_id" {
  value = aws_security_group.documentdb.id
}
