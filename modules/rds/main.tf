# RDS MySQL Instance
resource "aws_db_instance" "aws_boostup_rds_instance" {
  identifier = "${var.project_name}-${var.environment}-db"
  
  # Engine
  engine         = "mysql"
  engine_version = "8.0"
  
  # Instance class
  instance_class = var.instance_class
  
  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100  # Auto scaling up to 100GB
  storage_type          = "gp3"
  storage_encrypted     = true
  
  # Database config
  db_name  = replace(var.project_name, "-", "_")  # DB name cannot contain hyphens
  username = var.db_username
  password = var.db_password
  port     = 3306
  
  # Network
  db_subnet_group_name   = aws_db_subnet_group.aws_boostup_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aws_boostup_rds_sg.id]
  publicly_accessible    = false  # IMPORTANT: Keep private
  
  # High Availability
  multi_az = var.multi_az
  
  # Backup
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  
  # Deletion protection
  deletion_protection       = false  # Set to true for production
  skip_final_snapshot      = true    # Set to false for production
  final_snapshot_identifier = "${var.project_name}-${var.environment}-db_final_snapshot"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds"
    Environment = var.environment
  }
}
