# Monitoring Module - CloudWatch and CloudTrail

variable "environment" { type = string }
variable "application_name" { type = string }
variable "log_retention_days" { type = number }
variable "vpc_id" { type = string }
variable "alb_arn" { type = string }
variable "asg_name" { type = string }
variable "asg_arn" { type = string }
variable "db_instance_id" { type = string }
variable "cache_cluster_id" { type = string }
variable "storage_encrypted" { type = bool }
variable "kms_key_id" { type = string }
variable "alb_target_response_time_threshold" { type = number }
variable "alb_unhealthy_host_threshold" { type = number }
variable "asg_cpu_threshold" { type = number }
variable "asg_memory_threshold" { type = number }
variable "db_cpu_threshold" { type = number }
variable "cache_cpu_threshold" { type = number }
variable "common_tags" { type = map(string) }

# Application Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/${var.application_name}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.storage_encrypted ? var.kms_key_id : null

  tags = merge(var.common_tags, { Name = "${var.application_name}-app-logs" })
}

# Database Log Group
resource "aws_cloudwatch_log_group" "db" {
  name              = "/aws/${var.application_name}/${var.environment}/database"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.storage_encrypted ? var.kms_key_id : null

  tags = merge(var.common_tags, { Name = "${var.application_name}-db-logs" })
}

# S3 bucket for CloudTrail
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.application_name}-cloudtrail-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.common_tags, { Name = "${var.application_name}-cloudtrail" })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.application_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]

  tags = merge(var.common_tags, { Name = "${var.application_name}-trail" })
}

# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AWSCloudTrailAclCheck"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.cloudtrail.arn
    }, {
      Sid    = "AWSCloudTrailWrite"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }]
  })
}

data "aws_caller_identity" "current" {}

output "app_log_group_name" { value = aws_cloudwatch_log_group.app.name }
output "db_log_group_name" { value = aws_cloudwatch_log_group.db.name }
output "cloudtrail_s3_bucket" { value = aws_s3_bucket.cloudtrail.id }
