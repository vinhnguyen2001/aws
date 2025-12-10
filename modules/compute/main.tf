# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance for Backend API
resource "aws_instance" "api_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  
  vpc_security_group_ids = [aws_security_group.api_server_sg.id]
  
  key_name = var.key_name != null ? var.key_name : null
  
  user_data = templatefile("${path.module}/user_data.sh", {
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })

  tags = {
    Name        = "${var.project_name}-api-server"
    Environment = var.environment
  }
}

# Elastic IP for API Server
resource "aws_eip" "api_server_eip" {
  instance = aws_instance.api_server.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-api-eip"
    Environment = var.environment
  }
}
