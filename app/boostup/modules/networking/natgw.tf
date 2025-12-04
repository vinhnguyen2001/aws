# Elastic IP for NAT Gateways
resource "aws_eip" "aws_boostup_nat_eip" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.aws_boostup_igw]
}

# NAT Gateway (one per AZ for high availability)
resource "aws_nat_gateway" "aws_boostup_nat_gw" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.aws_boostup_nat_eip[count.index].id
  subnet_id     = aws_subnet.aws_boostup_public_subnet[count.index].id  # ← Fixed reference

  tags = {
    Name = "${var.project_name}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.aws_boostup_igw]
}