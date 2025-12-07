output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.aws_boostup_vpc.id
}


output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = aws_subnet.aws_boostup_public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = aws_subnet.aws_boostup_private_subnets[*].id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.aws_boostup_nat_gw.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.aws_boostup_igw.id
}
    
