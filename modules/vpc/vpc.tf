

# Retrieve the list of available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create the VPC
resource "aws_vpc" "aws_boostup_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "aws_boostup_igw" {
  vpc_id = aws_vpc.aws_boostup_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "aws_boostup_nat_eip" {
    
    tags = {
        Name        = "${var.project_name}-nat-eip"
        Environment = var.environment
    }
}

# Create NAT Gateway
resource "aws_nat_gateway" "aws_boostup_nat_gw" {
    allocation_id = aws_eip.aws_boostup_nat_eip.id
    subnet_id     = aws_subnet.aws_boostup_public_subnets[0].id #Gateway must be in a public subnet
    depends_on    = [aws_internet_gateway.aws_boostup_igw]
    tags = {
        Name        = "${var.project_name}-nat-gw"
        Environment = var.environment
    }
}

# Create Public Subnets
resource "aws_subnet" "aws_boostup_public_subnets" {
    count                   = length(var.public_subnets)
    vpc_id                  = aws_vpc.aws_boostup_vpc.id
    cidr_block              = var.public_subnets[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name        = "${var.project_name}-public-subnet-${count.index + 1}"
        Environment = var.environment
    }
}

# Create Private Subnets
resource "aws_subnet" "aws_boostup_private_subnets" {
    count             = length(var.private_subnets)
    vpc_id            = aws_vpc.aws_boostup_vpc.id
    cidr_block        = var.private_subnets[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name        = "${var.project_name}-private-subnet-${count.index + 1}"
        Environment = var.environment
    }
}

# Create Public Route Table and Associate with Public Subnets
resource "aws_route_table" "aws_boostup_public_rt" {
    vpc_id = aws_vpc.aws_boostup_vpc.id

    route {
        cidr_block = "0.0.0.0/0" # Destination: all IPs
        gateway_id = aws_internet_gateway.aws_boostup_igw.id
    }

    tags = {
        Name        = "${var.project_name}-public-rt"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "aws_boostup_public_assoc" {
    count          = length(var.public_subnets)
    subnet_id      = aws_subnet.aws_boostup_public_subnets[count.index].id
    route_table_id = aws_route_table.aws_boostup_public_rt.id
}

# Create Route Table for Private Subnets and Associate with Private Subnets
resource "aws_route_table" "aws_boostup_private_rt" {
    vpc_id = aws_vpc.aws_boostup_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.aws_boostup_nat_gw.id
    }

    tags = {
        Name        = "${var.project_name}-private-rt"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "aws_boostup_private_assoc" {
    count          = length(var.private_subnets)
    subnet_id      = aws_subnet.aws_boostup_private_subnets[count.index].id
    route_table_id = aws_route_table.aws_boostup_private_rt.id
}