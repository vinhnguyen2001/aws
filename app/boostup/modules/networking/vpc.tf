

# VPC Resource
resource "aws_vpc" "aws_boostup_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "${var.project_name}-vpc"
    }

}

# Internet Gateway Resource
resource "aws_internet_gateway" "aws_boostup_igw" {
    vpc_id = aws_vpc.aws_boostup_vpc.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}