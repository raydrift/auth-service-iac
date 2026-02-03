# Auth Service Module

Terraform module for deploying the auth-service microservice on Amazon ECS Fargate with full support for:
- Auto-scaling based on CPU and memory metrics
- CloudWatch logging with encryption
- Service discovery via AWS Cloud Map
- HIPAA compliance tagging and configuration
- Health checks and graceful deployments

## Architecture

This module deploys:
- **ECS Task Definition**: Containerized auth service configuration
- **ECS Service**: Manages desired task count and load balancer integration
- **Auto Scaling**: CPU and memory-based scaling policies
- **CloudWatch Logs**: Centralized logging with configurable retention
- **Security**: Role-based access control and encryption

## HIPAA Compliance Features

- ✅ Encrypted CloudWatch logs (KMS-managed)
- ✅ Secure container health checks
- ✅ Task-level IAM roles for least privilege
- ✅ VPC network isolation via security groups
- ✅ Audit logging via CloudWatch
- ✅ No public IP assignment by default
- ✅ Secrets management via AWS Secrets Manager
- ✅ Multi-AZ deployment capability

## Usage

```hcl
module "auth_service" {
  source = "./terraform/modules/auth_service"

  # Basic Configuration
  service_name        = "auth-service"
  container_image     = "012345678901.dkr.ecr.us-east-1.amazonaws.com/auth-service:v1.0.0"
  container_port      = 8080
  cluster_id          = aws_ecs_cluster.main.id
  cluster_name        = aws_ecs_cluster.main.name

  # Task Resources
  task_cpu            = 512
  task_memory         = 1024
  desired_count       = 3

  # IAM Roles
  execution_role_arn  = aws_iam_role.ecs_task_execution.arn
  task_role_arn       = aws_iam_role.ecs_task_role.arn

  # Networking
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  target_group_arn    = aws_lb_target_group.auth_service.arn

  # Logging
  log_group_name      = "/ecs/auth-service"
  log_retention_days  = 30
  log_encryption_key_id = aws_kms_key.logs.id

  # Auto Scaling
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 6
  autoscaling_cpu_target   = 70
  autoscaling_memory_target = 80

  # Environment & Secrets
  environment_variables = {
    LOG_LEVEL = "INFO"
    NODE_ENV  = "production"
  }

  secrets = {
    DATABASE_PASSWORD = aws_secretsmanager_secret.db_password.arn
  }

  # AWS Region
  aws_region = var.aws_region

  # Tags
  common_tags = {
    Project     = "auth-service"
    Environment = "production"
    Compliance  = "HIPAA"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `service_name` | Name of the ECS service | `string` | `"auth-service"` | no |
| `cluster_id` | ECS cluster ID | `string` | n/a | yes |
| `cluster_name` | ECS cluster name | `string` | n/a | yes |
| `container_image` | Docker image URI | `string` | n/a | yes |
| `container_port` | Container port | `number` | `8080` | no |
| `task_cpu` | CPU units (256, 512, 1024, 2048, 4096) | `number` | `512` | no |
| `task_memory` | Memory in MB | `number` | `1024` | no |
| `execution_role_arn` | ECS task execution role ARN | `string` | n/a | yes |
| `task_role_arn` | ECS task role ARN | `string` | n/a | yes |
| `desired_count` | Desired number of tasks | `number` | `3` | no |
| `subnet_ids` | VPC subnet IDs for tasks | `list(string)` | n/a | yes |
| `security_group_ids` | Security group IDs | `list(string)` | n/a | yes |
| `target_group_arn` | Load balancer target group ARN | `string` | n/a | yes |
| `log_group_name` | CloudWatch log group name | `string` | `"/ecs/auth-service"` | no |
| `log_retention_days` | Log retention in days | `number` | `30` | no |
| `log_encryption_key_id` | KMS key ID for encryption | `string` | `null` | no |
| `aws_region` | AWS region | `string` | n/a | yes |
| `environment_variables` | Container environment variables | `map(string)` | `{...}` | no |
| `secrets` | Secrets from AWS Secrets Manager | `map(string)` | `{}` | no |
| `enable_service_discovery` | Enable Cloud Map service discovery | `bool` | `false` | no |
| `service_registry_arn` | Cloud Map service registry ARN | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `ecs_service_id` | ECS service ID |
| `ecs_service_arn` | ECS service ARN |
| `task_definition_arn` | Task definition ARN |
| `log_group_name` | CloudWatch log group name |
| `service_summary` | Complete service configuration summary |

## Auto Scaling

The module includes automatic scaling based on:
- **CPU Utilization**: Scales when average CPU exceeds target (default 70%)
- **Memory Utilization**: Scales when average memory exceeds target (default 80%)

Scaling bounds:
- Minimum tasks: 2 (configurable)
- Maximum tasks: 6 (configurable)

## Security Considerations

1. **Network Isolation**: Deploy in private subnets without public IPs
2. **Encryption**: All logs encrypted with customer-managed KMS keys
3. **IAM Roles**: Minimal permissions via task role
4. **Secrets Management**: Use AWS Secrets Manager for sensitive values
5. **Health Checks**: Built-in HTTP health checking
6. **Logging**: Centralized CloudWatch logging with retention policies

## Compliance

- ✅ **HIPAA**: Encryption, audit logging, role-based access
- ✅ **Multi-AZ**: Automatic failover via ECS
- ✅ **Monitoring**: CloudWatch metrics and logs
- ✅ **Backup**: ECS manages task state

## Notes

- Task definition is versioned automatically on updates
- Service maintains desired count across AZs
- Deployment uses rolling updates (blue/green capable)
- ECS Exec can be enabled for debugging (requires IAM permissions)

---

**Module Version**: 0.1.0  
**Created**: 2025-02-02  
**Compliance**: HIPAA  
**Owner**: auth-service team
