# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-sg"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "app_db_subnet" {
  name       = "${var.app_name}-db-subnet"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# RDS MySQL Database
resource "aws_db_instance" "app_db" {
  identifier     = "${var.app_name}-db"
  engine         = "mysql"
  engine_version = "8.0.35"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_subnet_group_name   = aws_db_subnet_group.app_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az               = true
  publicly_accessible    = false
  backup_retention_period = 7

  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.app_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name = "${var.app_name}-rds"
  }

  depends_on = [aws_security_group.rds_sg]
}
