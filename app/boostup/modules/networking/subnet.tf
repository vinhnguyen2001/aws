
# Public Subnets (for ALB, NAT Gateway)
resource "aws_subnet" "aws_boostup_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.aws_boostup_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# Private Subnets (for EC2, RDS)
resource "aws_subnet" "aws_boostup_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.aws_boostup_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "Private"
  }
}