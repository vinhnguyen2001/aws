

#Module VPC 
module "vpc" {
  source = "../../modules/vpc"

  # Common variables
  project_name = var.project_name
  environment  = var.environment

  # VPC specific variables
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  region          = var.region
}

#Module RDS
module "rds" {
  source = "../../modules/rds"

  # Common variablesåß
  project_name = var.project_name
  environment  = var.environment

  # VPC related variables
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids

  # RDS-specific variables
  db_username       = var.db_username
  db_password       = var.db_password
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  multi_az          = var.db_multi_az
}
