# Outputs for Auth Service ECS Module

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.auth_service.id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.auth_service.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.auth_service.name
}

output "ecs_service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.auth_service.id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.auth_service.name
}

output "ecs_service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.auth_service.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.auth_service.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  value       = aws_cloudwatch_log_group.auth_service.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.auth_service.arn
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS service"
  value       = aws_security_group.ecs_service.id
}

output "task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "IAM role ARN for ECS tasks"
  value       = aws_iam_role.ecs_task_role.arn
}
