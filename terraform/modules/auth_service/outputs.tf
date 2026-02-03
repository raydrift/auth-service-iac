# Output Values for Auth Service Module

output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.auth_service.id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.auth_service.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.auth_service.arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.auth_service.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.auth_service.family
}

output "autoscaling_target_id" {
  description = "ID of the autoscaling target"
  value       = aws_appautoscaling_target.auth_service.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.auth_service[0].name, var.log_group_name)
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = try(aws_cloudwatch_log_group.auth_service[0].arn, "")
}

output "service_summary" {
  description = "Summary of the auth service configuration"
  value = {
    service_name       = aws_ecs_service.auth_service.name
    cluster_id         = var.cluster_id
    task_definition    = aws_ecs_task_definition.auth_service.family
    desired_count      = var.desired_count
    container_image    = var.container_image
    container_port     = var.container_port
    min_capacity       = var.autoscaling_min_capacity
    max_capacity       = var.autoscaling_max_capacity
    cpu_target         = var.autoscaling_cpu_target
    memory_target      = var.autoscaling_memory_target
    log_group          = try(aws_cloudwatch_log_group.auth_service[0].name, var.log_group_name)
    compliance_tags    = var.common_tags
  }
}
