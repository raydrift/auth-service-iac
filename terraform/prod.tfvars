# Production Environment Variables
environment         = "prod"
aws_region          = "us-east-1"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]

instance_type       = "t3.large"
desired_capacity    = 3
min_size            = 3
max_size            = 6

database_password   = ""  # Use AWS Secrets Manager in production
db_instance_class   = "db.t4g.large"
db_allocated_storage = 100
db_max_allocated_storage = 500

cache_node_type     = "cache.t4g.small"
cache_num_nodes     = 3

log_retention_days  = 90
