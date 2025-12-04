# Comprehensive Configuration Guide

This document explains each configuration variable and how to customize the infrastructure.

## Table of Contents
1. [Basic Configuration](#basic-configuration)
2. [Advanced Configuration](#advanced-configuration)
3. [Common Scenarios](#common-scenarios)

## Basic Configuration

### terraform.tfvars

```hcl
# Region Configuration
aws_region = "us-east-1"
# Other options: us-west-2, eu-west-1, ap-southeast-1, etc.

# Environment & Project
environment     = "dev"           # dev, staging, prod
project_name    = "web-app"
app_name        = "simple-web-app"

# Compute Configuration
instance_type   = "t3.micro"      # Free tier eligible
# Other options: t3.small ($10), t3.medium ($19), m5.large ($80)

# Database Configuration
db_name         = "webapp_db"
db_username     = "admin"
db_password     = "YourSecurePassword123!"  # CHANGE THIS!

# Scaling Configuration
min_size        = 1               # Minimum instances
max_size        = 3               # Maximum instances
desired_capacity = 2              # Currently running instances

# Storage Configuration
# Leave empty to auto-generate, or set custom name
# s3_bucket_name = "my-unique-bucket-name"
```

## Advanced Configuration

### Changing Instance Type

**Development (Low Cost)**
```bash
terraform apply -var="instance_type=t3.micro"
```

**Production (High Performance)**
```bash
terraform apply -var="instance_type=c5.xlarge"
```

### Auto Scaling Configuration

**Single Instance (Development)**
```bash
terraform apply \
  -var="min_size=1" \
  -var="max_size=1" \
  -var="desired_capacity=1"
```

**High Availability (Production)**
```bash
terraform apply \
  -var="min_size=2" \
  -var="max_size=10" \
  -var="desired_capacity=4"
```

### Database Configuration

**Small Database (Development)**
```hcl
# RDS instance will use db.t3.micro
# Allocated storage: 20 GB
# Multi-AZ: Enabled (for HA)
```

**Large Database (Production)**
```hcl
# To modify in rds.tf:
# instance_class = "db.r5.xlarge"  # Memory optimized
# allocated_storage = 100          # Larger storage
```

### Regional Deployment

**US Region (Default)**
```bash
terraform apply -var="aws_region=us-east-1"
```

**Europe Region**
```bash
terraform apply -var="aws_region=eu-west-1"
```

**Asia Pacific**
```bash
terraform apply -var="aws_region=ap-southeast-1"
```

---

## Common Scenarios

### Scenario 1: Production Deployment

```hcl
# terraform.tfvars
aws_region       = "us-west-2"
environment      = "prod"
project_name     = "my-company"
app_name         = "production-app"

instance_type    = "t3.small"          # Slightly larger
min_size         = 2
max_size         = 10
desired_capacity = 4

db_name          = "production_db"
db_username      = "prodadmin"
db_password      = "$(openssl rand -base64 16)"  # Generate random password

s3_bucket_name   = "my-company-prod-data-2024"
```

**Additional Production Changes:**
```bash
# 1. Edit terraform/rds.tf to enable encryption:
#    storage_encrypted = true
#    kms_key_id = aws_kms_key.db_key.arn

# 2. Edit terraform/alb.tf to add HTTPS:
#    https_certificate_arn = aws_acm_certificate.main.arn

# 3. Deploy with auto-approval
terraform apply -auto-approve
```

### Scenario 2: Development/Testing Environment

```hcl
# terraform.tfvars
aws_region       = "us-east-1"
environment      = "dev"
project_name     = "dev-testing"
app_name         = "dev-app"

instance_type    = "t3.micro"          # Free tier
min_size         = 1
max_size         = 2
desired_capacity = 1

db_name          = "dev_db"
db_username      = "devadmin"
db_password      = "DevPassword123"
```

### Scenario 3: Multi-Environment Setup

```bash
# Create workspaces for different environments
terraform workspace new production
terraform workspace new staging
terraform workspace new development

# Deploy to each workspace
terraform workspace select development
terraform apply -var-file="environments/dev.tfvars"

terraform workspace select staging
terraform apply -var-file="environments/staging.tfvars"

terraform workspace select production
terraform apply -var-file="environments/prod.tfvars"

# Switch between workspaces
terraform workspace select development
terraform output
```

### Scenario 4: Cost Optimization

**Minimal Cost Setup (Learning/Demo)**
```hcl
aws_region       = "us-east-1"
environment      = "demo"
instance_type    = "t3.micro"          # Free tier
min_size         = 1
max_size         = 1
desired_capacity = 1
```

**Budget Saved: ~80% vs. Production**

**Edit rds.tf** to reduce Multi-AZ:
```hcl
# Change from:
multi_az = true

# To:
multi_az = false  # Single AZ only
```

**Result:** ~$90/month → ~$20/month

### Scenario 5: High Traffic Configuration

```hcl
aws_region       = "us-west-2"
environment      = "prod-high-traffic"
instance_type    = "c5.2xlarge"        # Compute optimized
min_size         = 5
max_size         = 50
desired_capacity = 10

# Edit rds.tf:
# instance_class = "db.r5.2xlarge"
# allocated_storage = 200
```

---

## Environment-Specific Files

### Create directory structure:
```bash
mkdir -p terraform/environments
touch terraform/environments/dev.tfvars
touch terraform/environments/staging.tfvars
touch terraform/environments/prod.tfvars
```

### environments/dev.tfvars
```hcl
aws_region       = "us-east-1"
environment      = "dev"
app_name         = "dev-app"
instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1
db_password      = "DevPass123!"
```

### environments/staging.tfvars
```hcl
aws_region       = "us-east-1"
environment      = "staging"
app_name         = "staging-app"
instance_type    = "t3.small"
min_size         = 2
max_size         = 5
desired_capacity = 2
db_password      = "StagingPass123!"
```

### environments/prod.tfvars
```hcl
aws_region       = "us-west-2"
environment      = "prod"
app_name         = "production-app"
instance_type    = "t3.medium"
min_size         = 2
max_size         = 10
desired_capacity = 4
db_password      = "ProdPassword$(date +%s)!"
```

---

## Deployment Commands

### Deploy with Custom Variables
```bash
# One-off variable override
terraform apply -var="desired_capacity=5"

# Using variables file
terraform apply -var-file="environments/prod.tfvars"

# Multiple variable files
terraform apply \
  -var-file="environments/prod.tfvars" \
  -var="desired_capacity=8"

# All variables from CLI
terraform apply \
  -var="aws_region=eu-west-1" \
  -var="instance_type=t3.small" \
  -var="desired_capacity=3"
```

### Scaling Examples

**Scale Up for Traffic Spike**
```bash
# Temporarily increase capacity
terraform apply -var="desired_capacity=10"

# And increase max size
terraform apply \
  -var="desired_capacity=10" \
  -var="max_size=20"
```

**Scale Down to Save Costs**
```bash
# Reduce instances during off-hours
terraform apply \
  -var="desired_capacity=1" \
  -var="min_size=1"

# Or fully disable
terraform destroy
```

---

## Security Best Practices

### 1. Secure Password Management

**Option 1: AWS Secrets Manager**
```bash
# Store in Secrets Manager
aws secretsmanager create-secret \
  --name rds-password \
  --secret-string "$(openssl rand -base64 16)"

# Reference in Terraform
# db_password = data.aws_secretsmanager_secret_version.rds.secret_string
```

**Option 2: Use AWS Secrets Manager Integration**
```hcl
# In rds.tf
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Reference in terraform.tfvars
# db_password = random_password.db_password.result
```

**Option 3: Generate with CLI**
```bash
DB_PASSWORD=$(openssl rand -base64 16)
terraform apply -var="db_password=$DB_PASSWORD"
```

### 2. Sensitive Variables
```hcl
# In variables.tf - already configured!
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  # Terraform won't display in logs
}
```

### 3. Restricted IAM Policies
```hcl
# Already implemented - EC2 can only:
# - Access S3 bucket (not all buckets)
# - Write CloudWatch logs
# - No EC2 terminate permissions
# - No database admin permissions
```

---

## Monitoring and Alerts

### CloudWatch Alarms Configuration

Add to `terraform/monitoring.tf`:
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.app_name}-alerts"
}
```

---

## Backup and Recovery

### Automated Backups
```bash
# RDS backups (already enabled)
# Retention: 7 days
# Backup window: 03:00-04:00 UTC

# S3 versioning (already enabled)
# Keeps 30 day history

# EC2: Use AMI snapshots
aws ec2 create-image \
  --instance-id i-1234567890abcdef0 \
  --name app-backup-$(date +%Y%m%d)
```

---

## Disaster Recovery

### Full Infrastructure Backup
```bash
# Export Terraform state
terraform state pull > terraform.state.backup

# Create RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier simple-web-app-db \
  --db-snapshot-identifier backup-$(date +%Y%m%d-%H%M%S)

# Copy S3 bucket
aws s3 sync s3://simple-web-app-bucket s3://backup-bucket
```

### Restore From Backup
```bash
# If state is lost
terraform state push terraform.state.backup

# If database is lost
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier app-db-restored \
  --db-snapshot-identifier backup-snapshot-id

# If all lost, redeploy
terraform apply
```

---

**Last Updated:** December 2024
