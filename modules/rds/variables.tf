# Variables passed from root (common variables)
variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "vpc_id" {
    description = "VPC ID from VPC module"
    type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs from VPC module"
    type        = list(string)
}

# RDS-specific variables
variable "db_username" {
    description = "The username for the RDS database"
    type        = string
    default     = "admin"
}

variable "db_password" {
    description = "The password for the RDS database"
    type        = string
    sensitive   = true
}

variable "instance_class" {
    description = "The instance class for the RDS database"
    type        = string
    default     = "db.t3.micro"
}

variable "allocated_storage" {
    description = "Storage size in GB"
    type        = number
    default     = 20
}

variable "multi_az" {
    description = "Enable Multi-AZ deployment"
    type        = bool
    default     = false // false for development, true for production
}