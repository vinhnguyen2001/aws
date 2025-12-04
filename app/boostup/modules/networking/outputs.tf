# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.aws_boostup_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.aws_boostup_vpc.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.aws_boostup_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.aws_boostup_private_subnet[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.aws_boostup_public_subnet[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.aws_boostup_private_subnet[*].cidr_block
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.aws_boostup_igw.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.enable_nat_gateway ? aws_nat_gateway.aws_boostup_nat_gw[*].id : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = var.enable_nat_gateway ? aws_eip.aws_boostup_nat_eip[*].public_ip : []
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.aws_boostup_public_rt.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.aws_boostup_private_rt[*].id
}