output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_cluster_role_name" {
  value = aws_iam_role.eks_cluster.name
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "eks_node_role_name" {
  value = aws_iam_role.eks_node.name
}

output "alb_controller_role_arn" {
  value = try(aws_iam_role.alb_controller[0].arn, "")
}

output "ebs_csi_driver_role_arn" {
  value = try(aws_iam_role.ebs_csi_driver[0].arn, "")
}

output "efs_csi_driver_role_arn" {
  value = try(aws_iam_role.efs_csi_driver[0].arn, "")
}

output "rds_enhanced_monitoring_role_arn" {
  value = aws_iam_role.rds_enhanced_monitoring.arn
}

output "secrets_rotation_lambda_role_arn" {
  value = aws_iam_role.secrets_rotation_lambda.arn
}
