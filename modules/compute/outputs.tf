output "api_server_public_ip" {
  description = "Public IP of the API server"
  value       = aws_eip.api_server_eip.public_ip
}

output "api_server_id" {
  description = "ID of the API server instance"
  value       = aws_instance.api_server.id
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://${aws_eip.api_server_eip.public_ip}:3000"
}

output "api_server_sg_id" {
  description = "Security group ID of the API server"
  value       = aws_security_group.api_server_sg.id
}
