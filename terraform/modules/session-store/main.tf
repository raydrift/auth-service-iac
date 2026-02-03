# Session Store Module - DynamoDB

variable "environment" { type = string }
variable "application_name" { type = string }
variable "table_name" { type = string }
variable "billing_mode" { type = string }
variable "point_in_time_recovery" { type = bool }
variable "stream_enabled" { type = bool }
variable "storage_encrypted" { type = bool }
variable "kms_key_id" { type = string }
variable "ttl_attribute_name" { type = string }
variable "ttl_enabled" { type = bool }
variable "common_tags" { type = map(string) }

# DynamoDB Table for Sessions
resource "aws_dynamodb_table" "sessions" {
  name             = var.table_name
  billing_mode     = var.billing_mode
  hash_key         = "session_id"
  stream_specification {
    stream_view_type = var.stream_enabled ? "NEW_AND_OLD_IMAGES" : null
  }

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.ttl_enabled
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  server_side_encryption {
    enabled     = var.storage_encrypted
    kms_key_arn = var.kms_key_id
  }

  tags = merge(var.common_tags, { Name = var.table_name })
}

output "dynamodb_table_name" { value = aws_dynamodb_table.sessions.name }
output "dynamodb_table_arn" { value = aws_dynamodb_table.sessions.arn }
