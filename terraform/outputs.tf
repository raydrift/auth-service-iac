# Outputs for Auth Service Infrastructure

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.compute.alb_arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}

output "redis_endpoint" {
  description = "Redis cache endpoint"
  value       = module.cache.redis_endpoint
  sensitive   = true
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for sessions"
  value       = module.session_store.dynamodb_table_name
}

output "app_log_group_name" {
  description = "CloudWatch log group name for application logs"
  value       = module.monitoring.app_log_group_name
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = module.monitoring.cloudtrail_s3_bucket
}

output "security_group_ids" {
  description = "Security group IDs"
  value = {
    alb = module.networking.alb_security_group_id
    app = module.networking.app_security_group_id
    db  = module.networking.db_security_group_id
  }
}

output "kms_key_arns" {
  description = "ARNs of KMS keys used for encryption"
  value = {
    rds       = module.encryption.rds_key_arn
    ebs       = module.encryption.ebs_key_arn
    cache     = module.encryption.cache_key_arn
    dynamodb  = module.encryption.dynamodb_key_arn
    logs      = module.encryption.logs_key_arn
  }
  sensitive = true
}
