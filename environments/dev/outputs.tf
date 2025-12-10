# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# RDS Outputs
output "db_endpoint" {
  description = "RDS endpoint for database connection"
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "db_port" {
  description = "Database port"
  value       = module.rds.db_port
}

# S3 Outputs
output "website_url" {
  description = "S3 static website URL"
  value       = module.s3.website_url
}

# Compute Outputs
output "api_server_public_ip" {
  description = "Public IP of the API server"
  value       = module.compute.api_server_public_ip
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = module.compute.api_endpoint
}
