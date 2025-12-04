# Simple Web Application on AWS (Terraform Managed)

A complete, production-ready web application infrastructure hosted on AWS and managed entirely with Terraform. This project demonstrates best practices for infrastructure as code.

## 🏗️ Architecture Overview

### AWS Services Used

1. **EC2 (Auto Scaling Group)** - Compute instances running Node.js application
2. **RDS (MySQL)** - Relational database for persistent data
3. **S3** - Object storage for application data and backups
4. **Application Load Balancer (ALB)** - Distributes traffic across instances
5. **VPC** - Isolated virtual network with public/private subnets
6. **Security Groups** - Network-level access control
7. **IAM** - Identity and access management
8. **CloudWatch** - Monitoring and logging

## 📋 Prerequisites

### Required Software

```bash
# macOS
brew install terraform aws-cli

# Or download from:
# - Terraform: https://www.terraform.io/downloads.html
# - AWS CLI: https://aws.amazon.com/cli/
```

### AWS Credentials

```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## 🚀 Deployment

### Step 1: Clone and Navigate to Project

```bash
cd /Users/nguyentranngocvinh/Documents/Project/lab/aws/boostup/terraform
```

### Step 2: Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your desired values
nano terraform.tfvars
```

### Step 3: Initialize Terraform

```bash
terraform init
```

This command:
- Downloads required Terraform providers
- Initializes the working directory
- Creates `.terraform` directory with backend configuration

### Step 4: Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the planned changes before applying.

### Step 5: Apply the Configuration

```bash
terraform apply tfplan
```

This will:
- Create VPC with public and private subnets
- Launch ALB and configure routing
- Create Auto Scaling Group with EC2 instances
- Launch RDS MySQL database
- Create S3 bucket with security settings
- Configure all security groups and IAM roles

**Estimated deployment time: 10-15 minutes**

### Step 6: Access Your Application

```bash
# Get the load balancer DNS name
terraform output app_url

# Or directly
terraform output alb_dns_name

# Open in browser
open $(terraform output -raw app_url)
```

## 📊 Project Structure

```
boostup/
├── terraform/
│   ├── main.tf                 # Provider and general configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   ├── vpc.tf                  # VPC, subnets, routing
│   ├── alb.tf                  # Application Load Balancer
│   ├── ec2.tf                  # EC2, Auto Scaling Group, IAM
│   ├── rds.tf                  # RDS MySQL database
│   ├── s3.tf                   # S3 bucket with configuration
│   ├── user_data.sh            # EC2 initialization script
│   ├── terraform.tfvars.example # Example variables file
│   └── terraform.tfvars        # Your actual variables (gitignored)
└── app/
    ├── app.js                  # Node.js Express application
    └── package.json            # Node dependencies
```

## 🔧 Configuration Options

### Essential Variables (terraform.tfvars)

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | us-east-1 | AWS region for deployment |
| `environment` | dev | Environment name (dev, staging, prod) |
| `app_name` | simple-web-app | Application name |
| `instance_type` | t3.micro | EC2 instance type |
| `min_size` | 1 | Minimum EC2 instances |
| `max_size` | 3 | Maximum EC2 instances |
| `desired_capacity` | 2 | Desired EC2 instances |
| `db_password` | - | **Change this!** RDS password |

### Customization Examples

```bash
# Deploy to different region
terraform apply -var="aws_region=us-west-2"

# Scale up instances
terraform apply -var="desired_capacity=5" -var="max_size=10"

# Use larger database
terraform apply -var="instance_type=t3.small"
```

## 📤 Outputs

After deployment, Terraform provides:

```bash
terraform output

# Individual outputs
terraform output alb_dns_name      # Load balancer DNS
terraform output s3_bucket_name    # S3 bucket name
terraform output rds_endpoint      # Database endpoint
terraform output app_url           # Full application URL
```

## 🔍 Monitoring

### CloudWatch Logs

```bash
# View EC2 application logs
aws logs tail /aws/ec2/web-app --follow

# View RDS events
aws events list-events --source aws.rds
```

### Check Infrastructure Status

```bash
# List EC2 instances
aws ec2 describe-instances --region us-east-1 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn 2>/dev/null)

# Check RDS status
aws rds describe-db-instances --db-instance-identifier simple-web-app-db
```

## 🗑️ Cleanup

To destroy all resources and avoid unnecessary charges:

```bash
terraform destroy
```

Confirm the action. This will:
- Terminate EC2 instances
- Delete RDS database
- Remove S3 bucket
- Delete VPC and networking resources
- Remove security groups and IAM roles

**Warning:** This action is irreversible for most resources. Ensure you have backups if needed.

## 🔐 Security Best Practices

✅ **Already Implemented:**
- Private subnets for databases and instances
- Security groups with least-privilege access
- S3 bucket with encryption and public access blocking
- IAM roles for EC2 instances (no hardcoded credentials)
- VPC with NAT gateways for private instance internet access
- Database Multi-AZ for high availability

**Additional Recommendations:**
- Use AWS Secrets Manager for database passwords
- Enable VPC Flow Logs for network monitoring
- Enable S3 bucket logging
- Implement SSL/TLS certificates for ALB
- Use AWS WAF for additional protection
- Enable CloudTrail for audit logging

## 🐛 Troubleshooting

### Instances not launching

```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-web-app-asg

# View EC2 launch errors
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,StateTransitionReason]'
```

### Database connection errors

```bash
# Verify security group allows access from EC2
aws ec2 describe-security-groups --group-ids <rds-sg-id>

# Test connectivity from EC2 instance
# SSH into instance and run: mysql -h <db-endpoint> -u admin -p
```

### ALB not routing traffic

```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <tg-arn>

# Verify security group rules
aws ec2 describe-security-groups --group-ids <alb-sg-id>
```

## 📚 Learning Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 💡 Next Steps

### Enhancement Ideas

1. **Add HTTPS/TLS**
   - Use AWS Certificate Manager
   - Update ALB listener to use HTTPS

2. **Database Backups**
   - Configure automated snapshots
   - Implement cross-region replication

3. **Monitoring & Alerts**
   - Set up CloudWatch alarms
   - Configure SNS notifications

4. **CI/CD Pipeline**
   - Integrate with GitHub Actions
   - Automate Terraform deployments

5. **Multi-Environment Setup**
   - Create separate workspaces
   - Use different tfvars for each environment

6. **Application Scaling**
   - Implement database caching with ElastiCache
   - Add CloudFront CDN for static content

## 📝 License

This project is provided as-is for educational purposes.

## 🤝 Support

For issues or questions:
1. Check AWS documentation
2. Review Terraform logs: `TF_LOG=DEBUG terraform apply`
3. Check EC2 user data logs: `/var/log/cloud-init-output.log`

---

**Created:** December 2024
**Infrastructure as Code:** Terraform
**Cloud Provider:** AWS
