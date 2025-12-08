resource "aws_db_subnet_group" "aws_boostup_rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  


  tags = {
    Name        = "${var.project_name}-rds-subnet-group"
    Environment = var.environment
  }
}