# Cache Module - ElastiCache Redis

variable "environment" { type = string }
variable "application_name" { type = string }
variable "engine_version" { type = string }
variable "node_type" { type = string }
variable "num_cache_nodes" { type = number }
variable "automatic_failover" { type = bool }
variable "storage_encrypted" { type = bool }
variable "kms_key_id" { type = string }
variable "vpc_id" { type = string }
variable "cache_subnet_ids" { type = list(string) }
variable "cache_security_group_id" { type = string }
variable "common_tags" { type = map(string) }

# Cache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-cache-subnet-group"
  subnet_ids = var.cache_subnet_ids

  tags = merge(var.common_tags, { Name = "${var.environment}-cache-subnet-group" })
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "auth" {
  cluster_id           = "${var.application_name}-${var.environment}"
  engine               = "redis"
  node_type           = var.node_type
  num_cache_nodes     = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  engine_version      = var.engine_version
  port                = 6379
  subnet_group_name   = aws_elasticache_subnet_group.main.name
  security_group_ids  = [var.cache_security_group_id]
  at_rest_encryption_enabled = var.storage_encrypted
  transit_encryption_enabled = true
  auth_token_enabled  = true
  auth_token          = random_password.redis_auth_token.result

  tags = merge(var.common_tags, { Name = "${var.application_name}-${var.environment}" })
}

# Generate random auth token for Redis
resource "random_password" "redis_auth_token" {
  length  = 32
  special = true
}

output "redis_endpoint" { value = aws_elasticache_cluster.auth.cache_nodes[0].address }
output "redis_port" { value = aws_elasticache_cluster.auth.port }
output "cache_cluster_id" { value = aws_elasticache_cluster.auth.cluster_id }
