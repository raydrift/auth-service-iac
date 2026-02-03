# Input Variables for Auth Service Module

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "auth-service"
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "container_image" {
  description = "Docker image URI for the auth service"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory in MB for the task (512, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192)"
  type        = number
  default     = 1024
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "desired_count" {
  description = "Number of desired ECS tasks"
  type        = number
  default     = 3
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS task networking"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for load balancer"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = "/ecs/auth-service"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "log_encryption_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default = {
    LOG_LEVEL = "INFO"
    NODE_ENV  = "production"
  }
}

variable "secrets" {
  description = "Secrets from AWS Secrets Manager"
  type        = map(string)
  default     = {}
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks"
  type        = bool
  default     = false
}

variable "deployment_max_percent" {
  description = "Maximum percentage of desired tasks during deployment"
  type        = number
  default     = 200
}

variable "deployment_min_percent" {
  description = "Minimum percentage of desired tasks during deployment"
  type        = number
  default     = 100
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 6
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70

  validation {
    condition     = var.autoscaling_cpu_target > 0 && var.autoscaling_cpu_target < 100
    error_message = "CPU target must be between 1 and 99."
  }
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80

  validation {
    condition     = var.autoscaling_memory_target > 0 && var.autoscaling_memory_target < 100
    error_message = "Memory target must be between 1 and 99."
  }
}

variable "enable_service_discovery" {
  description = "Enable AWS Cloud Map service discovery"
  type        = bool
  default     = false
}

variable "service_registry_arn" {
  description = "ARN of the service registry for Cloud Map"
  type        = string
  default     = null
}

variable "enable_exec_command" {
  description = "Enable ECS Exec for task debugging"
  type        = bool
  default     = false
}

variable "create_log_group" {
  description = "Create CloudWatch log group (set to false if using existing)"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "auth-service"
    Environment = "production"
    Compliance  = "HIPAA"
    ManagedBy   = "Terraform"
  }
}
