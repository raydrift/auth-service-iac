# Dev Environment Variables
environment         = "dev"
aws_region          = "us-east-1"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b"]

instance_type       = "t3.medium"
desired_capacity    = 2
min_size            = 2
max_size            = 4

database_password   = "DevPassword123!@#"  # Change in real deployment
db_instance_class   = "db.t4g.medium"
db_allocated_storage = 20
db_max_allocated_storage = 100

cache_node_type     = "cache.t4g.micro"
cache_num_nodes     = 1

log_retention_days  = 7
