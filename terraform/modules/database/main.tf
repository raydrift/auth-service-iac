# Database Module - RDS Aurora PostgreSQL

variable "environment" { type = string }
variable "application_name" { type = string }
variable "database_name" { type = string }
variable "database_username" { type = string }
variable "database_password" { type = string; sensitive = true }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "max_allocated_storage" { type = number }
variable "storage_encrypted" { type = bool }
variable "kms_key_id" { type = string }
variable "multi_az" { type = bool }
variable "backup_retention_days" { type = number }
variable "backup_window" { type = string }
variable "maintenance_window" { type = string }
variable "vpc_id" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "db_security_group_id" { type = string }
variable "enable_cloudwatch_logs" { type = bool }
variable "log_group_name" { type = string }
variable "common_tags" { type = map(string) }

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(var.common_tags, { Name = "${var.environment}-db-subnet-group" })
}

# RDS Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "auth" {
  cluster_identifier              = "${var.application_name}-${var.environment}"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  database_name                   = var.database_name
  master_username                 = var.database_username
  master_password                 = var.database_password
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [var.db_security_group_id]
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  backup_retention_period         = var.backup_retention_days
  preferred_backup_window         = var.backup_window
  preferred_maintenance_window    = var.maintenance_window
  skip_final_snapshot             = var.environment != "prod"
  final_snapshot_identifier       = "${var.application_name}-${var.environment}-final-snapshot"
  enabled_cloudwatch_logs_exports = var.enable_cloudwatch_logs ? ["postgresql"] : []

  tags = merge(var.common_tags, { Name = "${var.application_name}-${var.environment}-cluster" })
}

# RDS Cluster Instance
resource "aws_rds_cluster_instance" "auth" {
  cluster_identifier           = aws_rds_cluster.auth.id
  instance_class               = var.instance_class
  engine                       = aws_rds_cluster.auth.engine
  engine_version               = aws_rds_cluster.auth.engine_version
  publicly_accessible          = false
  auto_minor_version_upgrade   = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  performance_insights_kms_key_id = var.kms_key_id

  tags = merge(var.common_tags, { Name = "${var.application_name}-${var.environment}-instance" })
}

# IAM Role for RDS Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.application_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

output "db_endpoint" { value = aws_rds_cluster.auth.endpoint }
output "db_port" { value = aws_rds_cluster.auth.port }
output "db_instance_id" { value = aws_rds_cluster_instance.auth.identifier }
