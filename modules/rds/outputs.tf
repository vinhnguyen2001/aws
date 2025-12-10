output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.aws_boostup_rds_instance.id
}

output "db_endpoint" {
  description = "The connection endpoint (hostname:port)"
  value       = aws_db_instance.aws_boostup_rds_instance.endpoint
}

output "db_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.aws_boostup_rds_instance.address
}

output "db_port" {
  description = "The database port"
  value       = aws_db_instance.aws_boostup_rds_instance.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.aws_boostup_rds_instance.db_name
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.aws_boostup_rds_instance.arn
}

output "db_resource_id" {
  description = "The RDS Resource ID"
  value       = aws_db_instance.aws_boostup_rds_instance.resource_id
}

output "db_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.aws_boostup_rds_sg.id
}
