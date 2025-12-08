# Project configuration
project_name = "aws boostup"
environment  = "dev"
region       = "us-east-1"

# VPC configuration
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

# RDS configuration
db_username         = "admin"
db_password         = "xxxAdmin123@"
db_instance_class   = "db.t3.micro"
db_allocated_storage = 20
db_multi_az         = false  # Set to true for production
