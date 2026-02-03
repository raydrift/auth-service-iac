# Auth Service Terraform Module

This Terraform module creates an ECS Fargate cluster for the Auth Service application.

## Components

- **ECS Cluster**: Fargate-based cluster with Container Insights monitoring
- **ECS Service**: Manages task deployment and scaling
- **ECS Task Definition**: Defines container configuration, logging, and environment
- **CloudWatch Logs**: Centralized logging for ECS tasks
- **Security Groups**: Network access controls for ECS tasks
- **IAM Roles**: Task execution and task roles with appropriate permissions

## Module Inputs

### Required Variables
- `vpc_id`: VPC ID where ECS cluster will be deployed
- `private_subnet_ids`: List of private subnet IDs for ECS tasks
- `alb_security_group_id`: Security group ID of the ALB
- `target_group_arn`: ARN of the ALB target group
- `aws_region`: AWS region

### Optional Variables
- `environment`: Environment name (dev, staging, prod) - default: "dev"
- `container_image`: Docker image URI - default: nginx:latest
- `container_port`: Container port - default: 3000
- `task_cpu`: Fargate task CPU - default: 256
- `task_memory`: Fargate task memory - default: 512
- `desired_count`: Desired number of tasks - default: 2
- `log_retention_days`: CloudWatch log retention - default: 7
- `log_level`: Application log level - default: INFO
- `common_tags`: Common resource tags

## Module Outputs

- `ecs_cluster_id`: ECS cluster ID
- `ecs_cluster_arn`: ECS cluster ARN
- `ecs_cluster_name`: ECS cluster name
- `ecs_service_id`: ECS service ID
- `ecs_service_name`: ECS service name
- `ecs_service_arn`: ECS service ARN
- `ecs_task_definition_arn`: Task definition ARN
- `cloudwatch_log_group_name`: CloudWatch log group name
- `cloudwatch_log_group_arn`: CloudWatch log group ARN
- `ecs_security_group_id`: ECS service security group ID
- `task_execution_role_arn`: Task execution role ARN
- `task_role_arn`: Task role ARN

## Usage

```hcl
module "auth_service" {
  source = "./modules/auth-service"

  aws_region            = "us-east-1"
  environment           = "prod"
  vpc_id                = aws_vpc.main.id
  private_subnet_ids    = aws_subnet.private[*].id
  alb_security_group_id = aws_security_group.alb.id
  target_group_arn      = aws_lb_target_group.main.arn
  
  container_image       = "your-registry/auth-service:1.0.0"
  container_port        = 3000
  task_cpu              = "512"
  task_memory           = "1024"
  desired_count         = 3
  log_retention_days    = 30
  
  common_tags = {
    Application = "auth-service"
    Environment = "prod"
    Owner       = "engineering-team"
  }
}
```

## Security Considerations

1. **Container Image**: Update `container_image` with your actual Docker image from ECR
2. **Network**: Tasks are deployed in private subnets without public IP assignment
3. **IAM**: Minimal IAM permissions granted for CloudWatch logs only
4. **Encryption**: Enable encryption for CloudWatch Logs if required
5. **Secrets Management**: Use AWS Secrets Manager for sensitive environment variables

## Naming Convention

All resources follow the `tf-{app}-{env}` naming pattern for consistency:
- Cluster: `tf-auth-service-{environment}`
- Service: `tf-auth-service-{environment}`
- Task Definition: `tf-auth-service-{environment}`
- Log Group: `/ecs/auth-service-{environment}`

## Compliance

This module is configured for:
- **HIPAA**: Tagged for compliance tracking
- **High Availability**: Multi-AZ deployment via multiple private subnets
- **Logging**: CloudWatch logs with configurable retention
- **Monitoring**: Container Insights enabled

## Cost Optimization

- Fargate Spot instances can be used for non-production workloads
- Adjust `task_cpu` and `task_memory` based on actual requirements
- Set appropriate `log_retention_days` to reduce log storage costs

## Troubleshooting

### Tasks not starting
- Check CloudWatch logs: `/ecs/auth-service-{environment}`
- Verify container image URI and availability in ECR
- Check security group rules allow ALB communication

### Service cannot reach database
- Verify security group egress rules allow database port
- Check database security group ingress rules
- Verify DNS resolution for database endpoint

## References

- [AWS ECS Fargate](https://aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
