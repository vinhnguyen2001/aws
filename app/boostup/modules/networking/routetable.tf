# Public Route Table
resource "aws_route_table" "aws_boostup_public_rt" {
  vpc_id = aws_vpc.aws_boostup_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_boostup_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
    Type = "Public"
  }
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "aws_boostup_private_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.aws_boostup_vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.aws_boostup_nat_gw[count.index].id
    }
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
    Type = "Private"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "aws_boostup_public_rta" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.aws_boostup_public_subnet[count.index].id
  route_table_id = aws_route_table.aws_boostup_public_rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "aws_boostup_private_rta" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.aws_boostup_private_subnet[count.index].id
  route_table_id = aws_route_table.aws_boostup_private_rt[count.index].id
}