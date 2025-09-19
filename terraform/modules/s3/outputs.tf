output "static_content_bucket_id" {
  value = aws_s3_bucket.static_content.id
}

output "static_content_bucket_arn" {
  value = aws_s3_bucket.static_content.arn
}

output "static_content_bucket_domain_name" {
  value = aws_s3_bucket.static_content.bucket_domain_name
}

output "static_content_bucket_regional_domain_name" {
  value = aws_s3_bucket.static_content.bucket_regional_domain_name
}

output "alb_logs_bucket_id" {
  value = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  value = aws_s3_bucket.alb_logs.arn
}

output "cloudfront_logs_bucket_id" {
  value = aws_s3_bucket.cloudfront_logs.id
}

output "cloudfront_logs_bucket_arn" {
  value = aws_s3_bucket.cloudfront_logs.arn
}

output "cloudfront_logs_bucket_domain_name" {
  value = aws_s3_bucket.cloudfront_logs.bucket_domain_name
}

output "backups_bucket_id" {
  value = aws_s3_bucket.backups.id
}

output "backups_bucket_arn" {
  value = aws_s3_bucket.backups.arn
}

output "kms_key_id" {
  value = aws_kms_key.s3.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.s3.arn
}
