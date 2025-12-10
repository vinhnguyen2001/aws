

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

#Module S3
module "s3" {
  source = "../../modules/s3"

  # Common variables
  project_name = var.project_name
  environment  = var.environment

  # S3 specific variables
  bucket_name               = var.bucket_name
  website_source_directory  = "${path.root}/../../source"
}

#Module Compute (EC2 for Backend API)
module "compute" {
  source = "../../modules/compute"

  # Common variables
  project_name = var.project_name
  environment  = var.environment

  # VPC related variables
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]

  # EC2 specific variables
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name != "" ? var.ec2_key_name : null

  # RDS connection variables
  db_endpoint           = module.rds.db_endpoint
  db_name               = module.rds.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  rds_security_group_id = module.rds.db_security_group_id
}
