output "cluster_id" {
  value = aws_eks_cluster.main.id
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  value = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  value = aws_eks_cluster.main.platform_version
}

output "cluster_security_group_id" {
  value = var.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "node_groups" {
  value = {
    on_demand = {
      id            = aws_eks_node_group.main.id
      arn           = aws_eks_node_group.main.arn
      status        = aws_eks_node_group.main.status
      capacity_type = aws_eks_node_group.main.capacity_type
    }
    spot = var.enable_spot_instances ? {
      id            = aws_eks_node_group.spot[0].id
      arn           = aws_eks_node_group.spot[0].arn
      status        = aws_eks_node_group.spot[0].status
      capacity_type = aws_eks_node_group.spot[0].capacity_type
    } : null
  }
}

output "kms_key_arn" {
  value = aws_kms_key.eks.arn
}

output "kms_key_id" {
  value = aws_kms_key.eks.key_id
}
