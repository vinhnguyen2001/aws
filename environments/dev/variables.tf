# Common variables
variable "project_name" {
  type    = string
  default = "boostup"
}

variable "environment" {
  type    = string
  default = "dev"
}

# RDS variables
variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

# VPC variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# S3 variables
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# EC2 variables
variable "ec2_instance_type" {
  description = "EC2 instance type for API server"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "SSH key pair name for EC2 instance (optional - set to empty string if not needed)"
  type        = string
  default     = ""
}
