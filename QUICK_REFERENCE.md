# Quick Reference Card

## 🚀 Deploy in 3 Steps

```bash
# 1. Configure
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Change db_password

# 2. Plan
terraform init
terraform plan

# 3. Deploy
terraform apply
```

**Time: 20 minutes**

---

## 📌 Essential Commands

### Terraform
```bash
terraform init              # Initialize
terraform plan             # Preview changes
terraform apply            # Deploy
terraform destroy          # Remove all
terraform output           # Show outputs
terraform fmt              # Format code
terraform validate         # Check syntax
```

### Quick Commands (Makefile)
```bash
make init                  # Initialize
make plan                  # Plan
make apply                 # Deploy & plan
make destroy               # Destroy
make output                # Show outputs
make status                # Check EC2 status
make help                  # Show all commands
```

### AWS CLI
```bash
# EC2 Instances
aws ec2 describe-instances

# Load Balancer
aws elbv2 describe-load-balancers

# Target Health
aws elbv2 describe-target-health --target-group-arn <arn>

# RDS Database
aws rds describe-db-instances

# S3 Buckets
aws s3 ls
```

---

## 🎯 Common Tasks

### Scale Up
```bash
terraform apply -var="desired_capacity=5"
```

### Scale Down
```bash
terraform apply -var="desired_capacity=1"
```

### Change Region
```bash
terraform apply -var="aws_region=eu-west-1"
```

### Change Instance Type
```bash
terraform apply -var="instance_type=t3.small"
```

### Get Application URL
```bash
terraform output app_url
```

### SSH to EC2 Instance
```bash
# Get instance IP
INSTANCE_IP=$(aws ec2 describe-instances \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

# SSH (if you have key setup)
ssh -i your-key.pem ec2-user@$INSTANCE_IP
```

---

## 📊 Key Outputs

```bash
# Get all outputs
terraform output

# Individual outputs
terraform output alb_dns_name      # Load balancer DNS
terraform output rds_endpoint      # Database endpoint
terraform output s3_bucket_name    # S3 bucket
terraform output app_url           # Full app URL
```

---

## 🔍 Monitoring

### Check EC2 Instances
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PrivateIpAddress]' \
  --output table
```

### Check Target Health
```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output alb_target_group_arn)
```

### Check RDS Status
```bash
aws rds describe-db-instances \
  --query 'DBInstances[0].[DBInstanceStatus,DBInstanceIdentifier]'
```

### Check S3 Bucket
```bash
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/
```

---

## ⚡ Troubleshooting Quick Fixes

### Instances Won't Start
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-web-app-asg
```

### ALB Returns 502
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

### Database Won't Connect
```bash
# Get endpoint
terraform output rds_endpoint

# Check from EC2
# SSH to instance then:
mysql -h <endpoint> -u admin -p
```

### Can't Find Application
```bash
# Get URL
APP_URL=$(terraform output -raw app_url)
curl $APP_URL
```

---

## 📚 Documentation Files

| File | Time | Use For |
|------|------|---------|
| INDEX.md | 5 min | Navigation |
| QUICKSTART.md | 5 min | Fast setup |
| README.md | 20 min | Full guide |
| ARCHITECTURE.md | 15 min | Design |
| CONFIGURATION.md | 15 min | Customization |
| TROUBLESHOOTING.md | Varies | Problem solving |
| DEPLOYMENT_CHECKLIST.md | 10 min | Best practices |
| RESOURCES.md | 10 min | Resource details |

---

## 🔐 Security Reminders

- ✅ Change `db_password` in terraform.tfvars
- ✅ Don't commit `terraform.tfvars` to git
- ✅ Don't expose `.gitignore` files
- ✅ Use AWS Secrets Manager for production
- ✅ Enable VPC Flow Logs for monitoring
- ✅ Add SSL/TLS for HTTPS

---

## 💰 Cost Control

### Check Monthly Costs
```bash
# Use AWS Console Cost Explorer
# Or estimate with pricing calculator
```

### Reduce Costs
```bash
# Single instance
terraform apply -var="desired_capacity=1" -var="max_size=1"

# Single-AZ database (edit rds.tf: multi_az = false)

# Smaller instance type
terraform apply -var="instance_type=t3.micro"

# Single NAT Gateway (edit vpc.tf)
```

---

## 📋 Variable Quick Reference

```hcl
aws_region         # AWS region (default: us-east-1)
environment        # dev/staging/prod (default: dev)
app_name           # Application name
instance_type      # EC2 type (default: t3.micro)
min_size           # Min instances (default: 1)
max_size           # Max instances (default: 3)
desired_capacity   # Current instances (default: 2)
db_password        # Database password (CHANGE THIS!)
s3_bucket_name     # S3 bucket name (auto-generated if empty)
```

---

## 🎯 Deployment Checklist

- [ ] Prerequisites installed (terraform, aws-cli)
- [ ] AWS credentials configured
- [ ] terraform.tfvars created and configured
- [ ] db_password changed from default
- [ ] terraform init completed
- [ ] terraform plan reviewed
- [ ] terraform apply executed
- [ ] Deployment completed (10-15 minutes)
- [ ] Application accessible via URL
- [ ] Instances healthy in ALB
- [ ] Database connection successful

---

## 🆘 When Something Goes Wrong

### Step 1: Check Logs
```bash
# EC2 user data
ssh ec2-instance
tail -f /var/log/cloud-init-output.log

# Application logs
pm2 logs

# Terraform logs
export TF_LOG=DEBUG
terraform apply
```

### Step 2: Verify Resources
```bash
# See all resources
terraform state list

# Check specific resource
terraform state show aws_lb.app_lb
```

### Step 3: Check AWS Console
- EC2 Dashboard → Instances
- RDS Dashboard → Databases
- S3 Dashboard → Buckets
- ELB Dashboard → Load Balancers

### Step 4: Read Documentation
- TROUBLESHOOTING.md → Find your error
- CONFIGURATION.md → Check settings
- README.md → Review basics

---

## 📞 Key Endpoints

```bash
# Application
$(terraform output -raw app_url)

# Database
$(terraform output -raw rds_endpoint)

# S3 Bucket
s3://$(terraform output -raw s3_bucket_name)

# ALB DNS
$(terraform output -raw alb_dns_name)
```

---

## 🔄 Cleanup

### Destroy All Resources
```bash
terraform destroy
```

### Clean Local Files
```bash
rm -rf .terraform
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -f tfplan
```

---

## ⏱️ Timeline

```
0 min    → Start
5 min    → Configuration ready
5 min    → terraform init
5 min    → terraform plan
15 min   → Deployment starts
20-30 min → Resources created
          EC2 instances: ~10 min
          RDS database: ~10 min
          ALB: ~2 min
30-40 min → Application ready
```

---

## 🎓 Learning Resources

### Quick Reads (5-15 minutes)
- QUICKSTART.md - Get started
- PROJECT_SUMMARY.md - Overview

### Full Guides (20-60 minutes)
- README.md - Complete reference
- ARCHITECTURE.md - System design

### Advanced Topics (Ongoing)
- CONFIGURATION.md - Customization
- All Terraform files - Code review

---

## 📌 Important Notes

⚠️ **Security**
- Change database password immediately
- Don't commit secrets to git
- Use IAM roles (no hardcoded credentials)

⚠️ **Costs**
- Monitor AWS bill regularly
- t3.micro is free tier eligible
- Use terraform destroy to stop charges

⚠️ **Best Practices**
- Always run terraform plan first
- Keep terraform.tfstate secure
- Use terraform workspace for environments
- Enable CloudWatch monitoring

---

## 🚀 Next Steps

1. **Deploy Now**
   - Read: QUICKSTART.md (5 min)
   - Configure: terraform.tfvars (5 min)
   - Deploy: terraform apply (20 min)

2. **Understand Design**
   - Read: ARCHITECTURE.md (15 min)
   - Review Terraform files (20 min)

3. **Customize**
   - Read: CONFIGURATION.md (15 min)
   - Modify variables (5 min)
   - Redeploy: terraform apply (10 min)

---

## 📞 Quick Help

| Need | File | Section |
|------|------|---------|
| Deploy | QUICKSTART.md | All |
| Understand | ARCHITECTURE.md | All |
| Customize | CONFIGURATION.md | Scenarios |
| Fix Issues | TROUBLESHOOTING.md | Find error |
| Best Practices | DEPLOYMENT_CHECKLIST.md | All |
| Navigate | INDEX.md | All |

---

**STATUS: ✅ Ready to Deploy**

**Start:** `cd terraform && terraform init`

**Questions?** Check INDEX.md

---

*This is a quick reference. For detailed information, see full documentation files.*
