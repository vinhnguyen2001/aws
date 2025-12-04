# Deployment Checklist

Use this checklist to ensure successful deployment of your AWS infrastructure.

## Pre-Deployment

### Prerequisites
- [ ] Terraform installed (`terraform -version`)
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS credentials configured (`aws configure`)
- [ ] Active AWS account with billing setup
- [ ] Appropriate IAM permissions (EC2, RDS, S3, VPC, IAM, ALB)

### Environment Setup
- [ ] Terminal/CLI ready
- [ ] Project directory available
- [ ] Git installed (optional, for version control)
- [ ] SSH key generated (if needed for EC2)

### Configuration
- [ ] Copy `terraform.tfvars.example` to `terraform.tfvars`
- [ ] Edit `db_password` - change from default
- [ ] Edit `s3_bucket_name` - use unique name or leave empty
- [ ] Review other variables for your use case
- [ ] Verify AWS region is correct

### Documentation
- [ ] Read README.md
- [ ] Review ARCHITECTURE.md to understand design
- [ ] Check QUICKSTART.md for steps
- [ ] Note TROUBLESHOOTING.md for issues

---

## Deployment Steps

### Step 1: Initialize
```bash
cd terraform
terraform init
```
- [ ] No errors during init
- [ ] `.terraform` directory created
- [ ] `.terraform.lock.hcl` created
- [ ] Provider downloaded

### Step 2: Validate
```bash
terraform validate
```
- [ ] Configuration is valid
- [ ] No syntax errors
- [ ] All references resolve

### Step 3: Plan
```bash
terraform plan -out=tfplan
```
- [ ] Plan completes successfully
- [ ] Resource count shows 30-40+ resources
- [ ] No unexpected deletions
- [ ] Review plan for your region/config

### Step 4: Preview Specific Resources
```bash
terraform plan | grep "Plan:"
```
- [ ] Correct number of resources to create
- [ ] No resources being destroyed
- [ ] Resource names look correct
- [ ] VPC CIDR is correct for your region

### Step 5: Apply
```bash
terraform apply tfplan
```
- [ ] Deployment starts
- [ ] No errors during creation
- [ ] Monitor for 10-15 minutes
- [ ] All resources complete successfully

### Step 6: Verify Outputs
```bash
terraform output
```
- [ ] ALB DNS name displayed
- [ ] S3 bucket name displayed
- [ ] RDS endpoint displayed
- [ ] Application URL accessible

---

## Post-Deployment Verification

### Infrastructure Checks

#### EC2 Instances
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,State.Name]'
```
- [ ] 1-2 instances running (depending on desired_capacity)
- [ ] Instances in "running" state
- [ ] Instances in private subnets
- [ ] Security group assigned correctly

#### Load Balancer
```bash
aws elbv2 describe-load-balancers
```
- [ ] ALB exists and active
- [ ] DNS name accessible
- [ ] In public subnets
- [ ] Security group allows port 80

#### Target Health
```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output alb_target_group_arn)
```
- [ ] Targets are "healthy"
- [ ] All EC2 instances registered
- [ ] Health checks passing
- [ ] No "unhealthy" targets

#### Database
```bash
aws rds describe-db-instances \
  --query 'DBInstances[0].[DBInstanceStatus,DBInstanceIdentifier]'
```
- [ ] Database status is "available"
- [ ] Database endpoint shows
- [ ] Multi-AZ is enabled
- [ ] Backup retention is 7 days

#### S3 Bucket
```bash
aws s3 ls s3://simple-web-app-bucket-*
```
- [ ] Bucket exists and accessible
- [ ] Versioning is enabled
- [ ] Encryption is enabled
- [ ] Public access is blocked

### Network Checks

#### VPC
```bash
aws ec2 describe-vpcs --filters "Name=cidr,Values=10.0.0.0/16"
```
- [ ] VPC exists
- [ ] CIDR block is 10.0.0.0/16
- [ ] DNS enabled

#### Subnets
```bash
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=<vpc-id>"
```
- [ ] 4 subnets total (2 public, 2 private)
- [ ] Public subnets have route to IGW
- [ ] Private subnets have route to NAT
- [ ] Subnets in different AZs

#### Security Groups
```bash
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*web-app*"
```
- [ ] ALB security group exists
- [ ] EC2 security group exists
- [ ] RDS security group exists
- [ ] Rules are correctly configured

### Application Checks

#### Access Application
```bash
APP_URL=$(terraform output -raw app_url)
curl $APP_URL
```
- [ ] Application responds with HTTP 200
- [ ] HTML page displays
- [ ] Page shows instance hostname
- [ ] Page shows AWS services information

#### Check Database
```bash
# SSH into EC2 instance
ssh ec2-user@<instance-ip>
mysql -h <rds-endpoint> -u admin -p<password> webapp_db
SELECT COUNT(*) FROM visitors;
```
- [ ] Database connection succeeds
- [ ] `visitors` table exists
- [ ] Records being created
- [ ] No SQL errors

#### Check Application Logs
```bash
# SSH into EC2 and check logs
ssh ec2-user@<instance-ip>
tail -f /var/log/cloud-init-output.log
pm2 logs
```
- [ ] Application started successfully
- [ ] No error messages
- [ ] Database connected
- [ ] S3 accessible

---

## Post-Deployment Configuration

### Security Hardening
- [ ] Change database password if needed
- [ ] Update security groups if needed
- [ ] Enable CloudWatch monitoring
- [ ] Set up SNS notifications
- [ ] Enable VPC Flow Logs

### Backup & Recovery
- [ ] Create manual RDS snapshot
- [ ] Backup Terraform state file
- [ ] Document backup location
- [ ] Test restore procedure

### Monitoring Setup
- [ ] Set up CloudWatch alarms
- [ ] Configure CPU threshold alarm
- [ ] Configure database connection alarm
- [ ] Configure ALB health alarm
- [ ] Enable detailed monitoring

### Documentation
- [ ] Document instance IPs
- [ ] Document database endpoint
- [ ] Document S3 bucket name
- [ ] Document ALB DNS name
- [ ] Save terraform outputs

---

## Operational Checks

### Daily
- [ ] Application responds
- [ ] No error logs
- [ ] Instances healthy
- [ ] Database accessible
- [ ] AWS bill looks normal

### Weekly
- [ ] Review CloudWatch metrics
- [ ] Check backup completion
- [ ] Review security groups
- [ ] Verify disaster recovery plan
- [ ] Update documentation

### Monthly
- [ ] Review AWS bill
- [ ] Optimize resources
- [ ] Update security patches
- [ ] Test backup restore
- [ ] Review scaling policies

---

## Scaling & Updates

### Scale Up
- [ ] Update desired_capacity in variables
- [ ] Run `terraform apply`
- [ ] Verify new instances launch
- [ ] Check load balancer distributes traffic

### Scale Down
- [ ] Update desired_capacity
- [ ] Run `terraform apply`
- [ ] Verify instances terminate gracefully
- [ ] Check database connections close

### Update Application
- [ ] SSH into EC2 instance
- [ ] Update application code
- [ ] Test application
- [ ] Restart application
- [ ] Verify ALB health checks pass

### Update Terraform
- [ ] Review `terraform plan` carefully
- [ ] Make changes in separate branch (git)
- [ ] Test in development first
- [ ] Apply changes during maintenance window
- [ ] Monitor for errors

---

## Troubleshooting Checklist

### If Instances Don't Start
- [ ] Check AMI ID is valid for region
- [ ] Verify security group exists
- [ ] Check IAM role has permissions
- [ ] Review Auto Scaling events
- [ ] Check capacity in AZ

### If ALB Returns 502
- [ ] Verify EC2 instances are running
- [ ] Check target health
- [ ] Verify security group allows port 80
- [ ] Check application is listening on port 80
- [ ] Review application logs

### If Database Won't Connect
- [ ] Verify RDS is in "available" state
- [ ] Check security group allows port 3306
- [ ] Verify database name exists
- [ ] Test from EC2 instance directly
- [ ] Review RDS events

### If S3 Access Fails
- [ ] Verify bucket exists
- [ ] Check IAM role has permissions
- [ ] Verify bucket policy (if custom)
- [ ] Check object permissions
- [ ] Review S3 access logs

---

## Cleanup Checklist

### Before Destroying
- [ ] Backup all data
- [ ] Export database
- [ ] Back up S3 contents
- [ ] Document configuration
- [ ] Save Terraform state
- [ ] Notify team members
- [ ] Archive documentation

### Destroy Infrastructure
```bash
terraform destroy
```
- [ ] Review resources to destroy
- [ ] Confirm deletion
- [ ] Verify all resources deleted
- [ ] Check AWS Console is empty
- [ ] Verify no charges incurred

### Post-Destruction
- [ ] Clean up local `.terraform` directory
- [ ] Remove `terraform.tfstate*` files
- [ ] Archive configuration
- [ ] Document lessons learned
- [ ] Update team documentation

---

## Disaster Recovery Verification

### RDS Failover
- [ ] Create manual RDS snapshot
- [ ] Verify standby replica exists
- [ ] Test failover manually
- [ ] Verify failback works
- [ ] Document RTO/RPO

### EC2 Instance Replacement
- [ ] Terminate healthy instance manually
- [ ] Verify replacement launches
- [ ] Verify ALB routes to replacement
- [ ] Check no data loss
- [ ] Document recovery time

### Data Recovery
- [ ] Restore from S3 snapshot
- [ ] Restore database from backup
- [ ] Verify data integrity
- [ ] Document recovery steps
- [ ] Test regularly

---

## Performance Baseline

Record these values for comparison:

```
Date: ____________

EC2 Metrics:
  - CPU Usage: ______ %
  - Memory: ______ MB
  - Network In: ______ Mbps
  - Network Out: ______ Mbps

RDS Metrics:
  - Connections: ______
  - CPU: ______ %
  - Database Connections: ______
  - Query Latency: ______ ms

ALB Metrics:
  - Active Connections: ______
  - Request Count: ______
  - Target Response Time: ______ ms

Application:
  - Page Load Time: ______ ms
  - Error Rate: ______ %
  - Visitor Count: ______
```

---

## Cost Tracking

Monthly expenses:
- Month 1: $______
- Month 2: $______
- Month 3: $______

Budget limit: $______

Actions if over budget:
- [ ] Reduce instance size
- [ ] Reduce desired capacity
- [ ] Convert to Reserved Instances
- [ ] Optimize data transfer

---

## Sign-Off

Deployment completed by: _______________
Date: _______________
Status: ☐ Complete  ☐ In Progress  ☐ Failed

Issues encountered: _________________________________
Resolution: _________________________________

---

**Checklist Version:** 1.0  
**Last Updated:** December 2024
