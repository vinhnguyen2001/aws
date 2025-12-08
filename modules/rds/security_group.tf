

# Security Group for RDS
resource "aws_security_group" "aws_boostup_rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Ingress: Allow MySQL from VPC
  ingress {
    description = "MySQL from VPC"
    from_port   = 3306 # MySQL's default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # allow all [var.vpc_cidr]
  }

  # Egress: Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}
