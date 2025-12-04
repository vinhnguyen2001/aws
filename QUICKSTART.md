# Quick Start Guide

## 5-Minute Setup

### Prerequisites Check
```bash
# Verify Terraform installation
terraform -version

# Verify AWS credentials
aws sts get-caller-identity

# If not configured:
aws configure
```

### Deploy Application

```bash
# 1. Navigate to project
cd /Users/nguyentranngocvinh/Documents/Project/lab/aws/boostup

# 2. Setup configuration
cd terraform
cp terraform.tfvars.example terraform.tfvars

# IMPORTANT: Edit terraform.tfvars and change:
# - db_password to something secure
# - s3_bucket_name if desired

# 3. Initialize Terraform
terraform init

# 4. Preview changes
terraform plan

# 5. Deploy (type 'yes' when prompted)
terraform apply

# ✅ Done! Wait 5-10 minutes for full deployment
```

### Access Application

```bash
# Get URL
terraform output app_url

# Or manually
ALB_DNS=$(terraform output -raw alb_dns_name)
open "http://$ALB_DNS"
```

---

## What Gets Deployed

✅ **AWS Services (5)**
- EC2 (Auto Scaling Group) - Application servers
- RDS - MySQL database  
- S3 - Object storage
- ALB - Load balancer
- VPC - Network infrastructure

✅ **Infrastructure**
- 2 public subnets (load balancer)
- 2 private subnets (applications & database)
- NAT gateways (2)
- Internet gateway
- Security groups

✅ **Application**
- Node.js web server
- Home page with stats
- Database integration
- Health check endpoint

---

## Estimated Costs

- **Free Tier**: First 12 months (if eligible)
- **Production Estimate**: $90-135/month
- **Development Estimate**: $20-30/month

---

## Key Commands

```bash
# View infrastructure outputs
terraform output

# Get specific value
terraform output app_url

# Plan changes without applying
terraform plan

# Apply specific resource
terraform apply -target=aws_lb.app_lb

# Destroy everything
terraform destroy

# Format configuration
terraform fmt -recursive

# Validate configuration
terraform validate
```

---

## Troubleshooting

**Instances not launching?**
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-web-app-asg
```

**Can't reach application?**
```bash
# Check if ALB is running
terraform output alb_dns_name

# Verify targets are healthy
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn 2>/dev/null)
```

**Database issues?**
```bash
# Get endpoint
terraform output rds_endpoint

# Test from local machine
mysql -h <endpoint> -u admin -p
```

**For more help:** See TROUBLESHOOTING.md

---

## Project Structure

```
boostup/
├── terraform/               # Terraform code
│   ├── *.tf                # Configuration files
│   ├── user_data.sh        # EC2 initialization
│   └── terraform.tfvars    # Your variables (create)
├── README.md               # Full documentation
├── ARCHITECTURE.md         # System design
├── CONFIGURATION.md        # Advanced setup
├── TROUBLESHOOTING.md      # Problem solving
├── Makefile                # Convenient commands
└── deploy.sh               # Automated deployment
```

---

## Next Steps

1. ✅ Deploy application
2. 📊 Monitor with CloudWatch
3. 🔒 Secure with SSL certificates
4. 📈 Set up auto-scaling policies
5. 🔄 Implement CI/CD pipeline

---

## Important Notes

⚠️ **Security**
- Change `db_password` in terraform.tfvars
- Never commit `terraform.tfvars` to git
- `.gitignore` is already configured

⚠️ **Costs**
- Monitor AWS bill regularly
- Use `terraform destroy` to stop charges
- Free tier eligible for t3.micro instances

⚠️ **Best Practices**
- Always run `terraform plan` before `apply`
- Keep `terraform.tfstate` secure
- Use `terraform workspace` for multiple environments

---

**Ready to deploy? Run:** `cd terraform && terraform init && terraform plan`
