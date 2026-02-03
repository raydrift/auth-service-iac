# Compute Module - ASG and Load Balancer (simplified)

variable "environment" { type = string }
variable "application_name" { type = string }
variable "instance_type" { type = string }
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "ami_owner" { type = string }
variable "ami_name_filter" { type = string }
variable "root_volume_size" { type = number }
variable "root_volume_type" { type = string }
variable "root_volume_encrypted" { type = bool }
variable "kms_key_id" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "alb_subnet_ids" { type = list(string) }
variable "app_security_group_id" { type = string }
variable "alb_security_group_id" { type = string }
variable "db_security_group_id" { type = string }
variable "db_endpoint" { type = string }
variable "db_port" { type = number }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "redis_endpoint" { type = string }
variable "redis_port" { type = number }
variable "dynamodb_table_name" { type = string }
variable "enable_monitoring" { type = bool }
variable "log_group_name" { type = string }
variable "common_tags" { type = map(string) }

# ALB
resource "aws_lb" "main" {
  name               = "${var.application_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.alb_subnet_ids

  enable_deletion_protection = var.environment == "prod"

  tags = merge(var.common_tags, { Name = "${var.application_name}-alb" })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.application_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = merge(var.common_tags, { Name = "${var.application_name}-tg" })
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.application_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.application_name}-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix            = "${var.application_name}-lt-"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.app_security_group_id]
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.kms_key_id
    delete_on_termination = true
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, { Name = "${var.application_name}-instance" })
  }
}

# IAM Role for EC2
resource "aws_iam_role" "app" {
  name = "${var.application_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.application_name}-profile"
  role = aws_iam_role.app.name
}

# Data source for AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_arn" { value = aws_lb.main.arn }
output "asg_name" { value = aws_autoscaling_group.main.name }
output "asg_arn" { value = aws_autoscaling_group.main.arn }
