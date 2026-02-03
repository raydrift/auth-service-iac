# Encryption Module - KMS Keys

variable "environment" { type = string }
variable "application_name" { type = string }
variable "enable_key_rotation" { type = bool }
variable "common_tags" { type = map(string) }

# KMS Key for RDS
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.common_tags, { Name = "${var.application_name}-rds-key" })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.application_name}-rds-${var.environment}"
  target_key_id = aws_kms_key.rds.key_id
}

# KMS Key for EBS
resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.common_tags, { Name = "${var.application_name}-ebs-key" })
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.application_name}-ebs-${var.environment}"
  target_key_id = aws_kms_key.ebs.key_id
}

# KMS Key for Cache
resource "aws_kms_key" "cache" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.common_tags, { Name = "${var.application_name}-cache-key" })
}

resource "aws_kms_alias" "cache" {
  name          = "alias/${var.application_name}-cache-${var.environment}"
  target_key_id = aws_kms_key.cache.key_id
}

# KMS Key for DynamoDB
resource "aws_kms_key" "dynamodb" {
  description             = "KMS key for DynamoDB encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.common_tags, { Name = "${var.application_name}-dynamodb-key" })
}

resource "aws_kms_alias" "dynamodb" {
  name          = "alias/${var.application_name}-dynamodb-${var.environment}"
  target_key_id = aws_kms_key.dynamodb.key_id
}

# KMS Key for Logs
resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = var.enable_key_rotation

  tags = merge(var.common_tags, { Name = "${var.application_name}-logs-key" })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.application_name}-logs-${var.environment}"
  target_key_id = aws_kms_key.logs.key_id
}

output "rds_key_id" { value = aws_kms_key.rds.id }
output "rds_key_arn" { value = aws_kms_key.rds.arn }
output "ebs_key_id" { value = aws_kms_key.ebs.id }
output "ebs_key_arn" { value = aws_kms_key.ebs.arn }
output "cache_key_id" { value = aws_kms_key.cache.id }
output "cache_key_arn" { value = aws_kms_key.cache.arn }
output "dynamodb_key_id" { value = aws_kms_key.dynamodb.id }
output "dynamodb_key_arn" { value = aws_kms_key.dynamodb.arn }
output "logs_key_id" { value = aws_kms_key.logs.id }
output "logs_key_arn" { value = aws_kms_key.logs.arn }
