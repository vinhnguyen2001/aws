# Troubleshooting Guide

## Common Issues and Solutions

### Terraform Issues

#### 1. "Provider Version Constraint"
**Problem:** Error about provider version constraints

```
Error: Unsupported provider version

Provider registry.terraform.io/hashicorp/aws with version
```

**Solution:**
```bash
# Update provider
terraform init -upgrade

# Or manually update version in main.tf
# Change: version = "~> 5.0"
# To: version = "~> 6.0"
```

#### 2. "Invalid AWS Credentials"
**Problem:** `Error: error configuring Terraform AWS Provider`

**Solution:**
```bash
# Check AWS credentials are configured
aws configure

# Verify credentials work
aws sts get-caller-identity

# Check environment variables
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
echo $AWS_DEFAULT_REGION
```

#### 3. "Terraform Lock File Issues"
**Problem:** `.terraform.lock.hcl` conflicts

**Solution:**
```bash
# Remove lock file and reinitialize
cd terraform
rm .terraform.lock.hcl
terraform init
```

#### 4. "State File Corruption"
**Problem:** `Error reading state file: unexpected EOF`

**Solution:**
```bash
# List backups
ls -la terraform.tfstate*

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Or manually recreate
terraform init
terraform refresh
```

---

### AWS Deployment Issues

#### 1. "EC2 Instances Not Launching"
**Problem:** Auto Scaling Group shows 0 running instances

**Diagnosis:**
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-web-app-asg \
  --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,Instances]'

# Check launch template
aws ec2 describe-launch-templates \
  --launch-template-names simple-web-app-lt

# Check for errors
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name simple-web-app-asg \
  --max-records 10
```

**Common Causes:**
- Invalid AMI ID for region
- Security group doesn't exist
- Insufficient capacity in AZ
- IAM role permissions issue

**Solution:**
```bash
# Update launch template AMI
terraform apply -var="instance_type=t3.micro"

# Or manually update AMI to your region
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*" \
  --query 'Images[0].ImageId'
```

#### 2. "ALB Not Routing Traffic"
**Problem:** Getting 502 Bad Gateway or connection timeout

**Diagnosis:**
```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn 2>/dev/null)

# Check ALB security group
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw alb_security_group_id 2>/dev/null)

# Test connectivity to ALB
curl -v $(terraform output -raw alb_dns_name)
```

**Common Causes:**
- EC2 instances marked as "unhealthy"
- Security group rules blocking traffic
- Port 80 not listening on EC2

**Solution:**
```bash
# SSH into EC2 instance and check application
# sudo systemctl status app (or your app manager)

# Check if port 80 is listening
sudo netstat -tlnp | grep :80

# Restart application
sudo systemctl restart app
```

#### 3. "Database Connection Failed"
**Problem:** Application can't connect to RDS

**Diagnosis:**
```bash
# Get RDS endpoint
terraform output rds_endpoint

# Test connection from EC2
# SSH into EC2 then:
mysql -h <endpoint> -u admin -p<password> -e "SELECT 1;"

# Check security group allows 3306
aws ec2 describe-security-groups \
  --group-ids <rds-security-group-id>
```

**Common Causes:**
- RDS not fully initialized (takes 5-10 minutes)
- Security group blocks EC2
- Wrong password in connection string
- Database not created yet

**Solution:**
```bash
# Wait for RDS to be available
aws rds describe-db-instances \
  --db-instance-identifier simple-web-app-db \
  --query 'DBInstances[0].DBInstanceStatus'

# Create database if missing
mysql -h <endpoint> -u admin -p<password> \
  -e "CREATE DATABASE IF NOT EXISTS webapp_db;"
```

#### 4. "S3 Permission Denied"
**Problem:** Application can't upload to S3

**Diagnosis:**
```bash
# Check IAM role policy
aws iam get-role-policy \
  --role-name simple-web-app-ec2-role \
  --policy-name s3-policy

# Test S3 access from EC2 (SSH into instance)
aws s3 ls s3://simple-web-app-bucket-<account-id>/
```

**Solution:**
```bash
# Update IAM policy
terraform apply -var="refresh_iam=true"

# Or manually verify bucket exists
terraform output s3_bucket_name
```

---

### Application Issues

#### 1. "Application Not Starting"
**Problem:** ALB shows unhealthy targets

**Diagnosis (SSH into EC2):**
```bash
# Check if application is running
ps aux | grep node

# Check logs
sudo journalctl -u app -n 50

# Or check application logs
tail -f /var/log/app-startup.log
```

**Common Causes:**
- Node.js not installed
- Dependencies not installed
- Port already in use
- Environment variables not set

**Solution:**
```bash
# SSH into instance and manually start app
cd /opt
npm install
node app.js

# Or check user_data script output
cat /var/log/cloud-init-output.log
```

#### 2. "Database Table Not Created"
**Problem:** Visitor data not being saved

**Diagnosis:**
```bash
# Connect to database (from EC2)
mysql -h <endpoint> -u admin -p<password> webapp_db

# List tables
SHOW TABLES;

# Check table structure
DESCRIBE visitors;
```

**Solution:**
```sql
-- Manually create table
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    request_path VARCHAR(255)
);
```

#### 3. "High CPU/Memory Usage"
**Problem:** Instances running slowly

**Solution:**
```bash
# Scale up instance size
terraform apply -var="instance_type=t3.small"

# Or increase Auto Scaling capacity
terraform apply -var="desired_capacity=3"

# Check application logs for leaks
ssh ec2-instance
ps aux | grep node
top -p <pid>
```

---

### Network Issues

#### 1. "Cannot Access Application from Internet"
**Problem:** ALB DNS name unreachable

**Diagnosis:**
```bash
# Check ALB is active
aws elbv2 describe-load-balancers \
  --names simple-web-app-alb

# Check listener is active
aws elbv2 describe-listeners \
  --load-balancer-arn <alb-arn>

# Test with curl
curl -v $(terraform output alb_dns_name)
```

**Solution:**
```bash
# Check firewall/ISP isn't blocking
nslookup $(terraform output alb_dns_name)

# Re-create ALB
terraform taint aws_lb.app_lb
terraform apply
```

#### 2. "NAT Gateway Issues"
**Problem:** Private instances can't reach internet

**Diagnosis:**
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways

# Check route table
aws ec2 describe-route-tables \
  --route-table-ids <private-rt-id>
```

**Solution:**
```bash
# Replace NAT Gateway
terraform taint aws_nat_gateway.nat_1
terraform apply
```

---

### Cost Issues

#### 1. "Unexpectedly High Bill"
**Problem:** AWS charges higher than expected

**Investigation:**
```bash
# Check resource costs
# Use AWS Cost Explorer console or:

# Estimate with AWS Pricing Calculator
# Check for:
# - Extra NAT Gateways
# - Data transfer out charges
# - Unused resources
# - Snapshot storage
```

**Cost Reduction:**
```bash
# Destroy unused resources
terraform destroy

# Or reduce resources
terraform apply \
  -var="desired_capacity=1" \
  -var="max_size=2"
```

---

### Debugging Commands

#### General AWS CLI Debugging
```bash
# Enable detailed logging
export AWS_DEBUG=true

# Or use verbose mode
aws ec2 describe-instances --debug

# Check AWS limits
aws service-quotas list-service-quotas \
  --service-code ec2
```

#### Terraform Debugging
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Trace specific resource
terraform apply -target aws_instance.example

# Validate configuration
terraform validate

# Format check
terraform fmt -check
```

#### EC2 Debugging (SSH)
```bash
# Connect to EC2 instance
ssh -i key.pem ec2-user@<public-ip>

# Check system logs
sudo tail -f /var/log/cloud-init-output.log
sudo tail -f /var/log/messages

# Check network
netstat -tlnp
ip addr
ping 8.8.8.8

# Check Docker (if applicable)
docker ps
docker logs <container>
```

#### RDS Debugging
```bash
# Check parameter group
aws rds describe-db-parameters \
  --db-instance-identifier simple-web-app-db

# View event log
aws rds describe-events \
  --source-type db-instance

# Check slow queries
# (Enable in parameter group, then view in logs)
```

---

## Getting Help

### AWS Support Resources
- [AWS Support](https://console.aws.amazon.com/support/home)
- [AWS Forum](https://forums.aws.amazon.com/)
- [AWS Documentation](https://docs.aws.amazon.com/)

### Terraform Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform)

### Collecting Logs for Support
```bash
# Collect Terraform logs
export TF_LOG=DEBUG
terraform plan > terraform_plan.log 2>&1

# Collect AWS CLI logs
aws ec2 describe-instances --debug > aws_debug.log 2>&1

# Collect application logs (from EC2)
scp ec2-user@<ip>:/var/log/cloud-init-output.log ./

# Create support bundle
tar czf support-bundle.tar.gz \
  terraform.log \
  aws_debug.log \
  cloud-init-output.log
```

---

**Last Updated:** December 2024
