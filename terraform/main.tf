# Auth Service - Root Terraform Module
# Orchestrates all infrastructure components

terraform {
  required_version = ">= 1.0"
  
  cloud {
    organization = "rosetta-poc"
    
    workspaces {
      name = "auth-service-iac"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  
  common_tags = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  environment              = var.environment
  application_name         = var.application_name
  instance_type            = var.instance_type
  desired_capacity         = var.desired_capacity
  min_size                 = var.min_size
  max_size                 = var.max_size
  ami_owner                = "amazon"
  ami_name_filter          = "amzn2-ami-hvm-*"
  root_volume_size         = 30
  root_volume_type         = "gp3"
  root_volume_encrypted    = true
  kms_key_id               = module.encryption.ebs_key_id

  vpc_id                   = module.networking.vpc_id
  private_subnet_ids       = module.networking.private_subnet_ids
  alb_subnet_ids           = module.networking.public_subnet_ids
  app_security_group_id    = module.networking.app_security_group_id
  alb_security_group_id    = module.networking.alb_security_group_id

  db_security_group_id     = module.networking.db_security_group_id
  db_endpoint              = module.database.db_endpoint
  db_port                  = module.database.db_port
  db_name                  = var.database_name
  db_username              = var.database_username

  redis_endpoint           = module.cache.redis_endpoint
  redis_port               = module.cache.redis_port

  dynamodb_table_name      = module.session_store.dynamodb_table_name

  enable_monitoring        = true
  log_group_name           = module.monitoring.app_log_group_name

  common_tags = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  environment              = var.environment
  application_name         = var.application_name
  database_name            = var.database_name
  database_username        = var.database_username
  database_password        = var.database_password
  
  engine_version           = "14.8"
  instance_class           = var.db_instance_class
  allocated_storage         = var.db_allocated_storage
  max_allocated_storage    = var.db_max_allocated_storage
  storage_encrypted        = true
  kms_key_id               = module.encryption.rds_key_id
  
  multi_az                 = true
  backup_retention_days    = 30
  backup_window            = "03:00-04:00"
  maintenance_window       = "mon:04:00-mon:05:00"
  
  vpc_id                   = module.networking.vpc_id
  db_subnet_ids            = module.networking.db_subnet_ids
  db_security_group_id     = module.networking.db_security_group_id
  
  enable_cloudwatch_logs   = true
  log_group_name           = module.monitoring.db_log_group_name
  
  common_tags = local.common_tags

  depends_on = [module.networking]
}

# Cache Module
module "cache" {
  source = "./modules/cache"

  environment              = var.environment
  application_name         = var.application_name
  engine_version           = "7.0"
  node_type                = var.cache_node_type
  num_cache_nodes          = var.cache_num_nodes
  automatic_failover       = true
  storage_encrypted        = true
  kms_key_id               = module.encryption.cache_key_id
  
  vpc_id                   = module.networking.vpc_id
  cache_subnet_ids         = module.networking.cache_subnet_ids
  cache_security_group_id  = module.networking.cache_security_group_id
  
  common_tags = local.common_tags

  depends_on = [module.networking]
}

# Session Store Module
module "session_store" {
  source = "./modules/session-store"

  environment              = var.environment
  application_name         = var.application_name
  table_name               = "${var.application_name}-sessions-${var.environment}"
  
  billing_mode             = "PAY_PER_REQUEST"
  point_in_time_recovery   = true
  stream_enabled           = false
  storage_encrypted        = true
  kms_key_id               = module.encryption.dynamodb_key_id
  
  ttl_attribute_name       = "expiration_time"
  ttl_enabled              = true
  
  common_tags = local.common_tags
}

# Encryption Module
module "encryption" {
  source = "./modules/encryption"

  environment              = var.environment
  application_name         = var.application_name
  enable_key_rotation      = true
  
  common_tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  environment              = var.environment
  application_name         = var.application_name
  log_retention_days       = var.log_retention_days
  
  vpc_id                   = module.networking.vpc_id
  alb_arn                  = module.compute.alb_arn
  asg_name                 = module.compute.asg_name
  asg_arn                  = module.compute.asg_arn
  db_instance_id           = module.database.db_instance_id
  cache_cluster_id         = module.cache.cache_cluster_id
  
  storage_encrypted        = true
  kms_key_id               = module.encryption.logs_key_id
  
  # Alert thresholds
  alb_target_response_time_threshold = 1000  # milliseconds
  alb_unhealthy_host_threshold       = 1
  asg_cpu_threshold                  = 80    # percent
  asg_memory_threshold               = 85    # percent
  db_cpu_threshold                   = 75    # percent
  cache_cpu_threshold                = 80    # percent
  
  common_tags = local.common_tags

  depends_on = [module.networking, module.compute, module.database, module.cache]
}
