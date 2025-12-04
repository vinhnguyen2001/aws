# AWS Resources Inventory

This document lists all AWS resources that will be created by this Terraform configuration.

## Resource Summary

**Total Resources:** 35-40 (depending on configuration)  
**Estimated Deployment Time:** 10-15 minutes  
**Regions:** Multi-region capable (default: us-east-1)

---

## VPC & Networking (10 resources)

### VPC
```
aws_vpc.app_vpc
├─ CIDR: 10.0.0.0/16
├─ DNS Hostnames: Enabled
└─ DNS Support: Enabled
```

### Internet Gateway
```
aws_internet_gateway.app_igw
└─ VPC: app_vpc
```

### Subnets (4 total)
```
aws_subnet.public_subnet_1        (10.0.1.0/24, AZ: us-east-1a)
aws_subnet.public_subnet_2        (10.0.2.0/24, AZ: us-east-1b)
aws_subnet.private_subnet_1       (10.0.10.0/24, AZ: us-east-1a)
aws_subnet.private_subnet_2       (10.0.11.0/24, AZ: us-east-1b)
```

### Elastic IPs (2 total)
```
aws_eip.nat_1                     (For NAT Gateway 1)
aws_eip.nat_2                     (For NAT Gateway 2)
```

### NAT Gateways (2 total)
```
aws_nat_gateway.nat_1            (In public_subnet_1)
aws_nat_gateway.nat_2            (In public_subnet_2)
```

### Route Tables (3 total)
```
aws_route_table.public_rt
├─ Route: 0.0.0.0/0 → IGW
├─ Association: public_subnet_1
└─ Association: public_subnet_2

aws_route_table.private_rt_1
├─ Route: 0.0.0.0/0 → NAT_1
└─ Association: private_subnet_1

aws_route_table.private_rt_2
├─ Route: 0.0.0.0/0 → NAT_2
└─ Association: private_subnet_2
```

### Route Table Associations (4 total)
```
aws_route_table_association.public_1
aws_route_table_association.public_2
aws_route_table_association.private_1
aws_route_table_association.private_2
```

---

## Load Balancer (4 resources)

### Security Group
```
aws_security_group.alb_sg
├─ Inbound: 0.0.0.0/0:80 (HTTP)
├─ Inbound: 0.0.0.0/0:443 (HTTPS - for future)
└─ Outbound: All traffic
```

### Application Load Balancer
```
aws_lb.app_lb
├─ Type: Application Load Balancer
├─ Subnets: public_subnet_1, public_subnet_2
├─ Security Group: alb_sg
└─ Deletion Protection: Disabled
```

### Target Group
```
aws_lb_target_group.app_tg
├─ Protocol: HTTP (Port 80)
├─ Health Check: /health
├─ Healthy Threshold: 2
├─ Unhealthy Threshold: 2
└─ Interval: 30 seconds
```

### Listener
```
aws_lb_listener.app_listener
├─ Port: 80 (HTTP)
├─ Protocol: HTTP
└─ Default Action: Forward to target group
```

---

## Compute (EC2 & Auto Scaling) (6 resources)

### Security Group
```
aws_security_group.ec2_sg
├─ Inbound: From ALB on port 80
├─ Inbound: From ALB on port 443
├─ Outbound: All traffic (0.0.0.0/0)
└─ VPC: app_vpc
```

### Launch Template
```
aws_launch_template.app_template
├─ Image: Ubuntu 22.04 LTS (Latest)
├─ Instance Type: t3.micro (configurable)
├─ Security Group: ec2_sg
├─ User Data: Initialization script
├─ IAM Instance Profile: ec2_profile
└─ Lifecycle: Create before destroy
```

### Auto Scaling Group
```
aws_autoscaling_group.app_asg
├─ Min Size: 1 (configurable)
├─ Max Size: 3 (configurable)
├─ Desired Capacity: 2 (configurable)
├─ Subnets: private_subnet_1, private_subnet_2
├─ Target Group: app_tg
├─ Health Check Type: ELB
└─ Launch Template: app_template
```

### IAM Role
```
aws_iam_role.ec2_role
├─ Service: EC2
└─ Trust Policy: EC2 service
```

### IAM Policies (2 total)
```
aws_iam_role_policy.ec2_s3_policy
├─ GetObject
├─ PutObject
├─ ListBucket
└─ Resource: S3 bucket

aws_iam_role_policy.ec2_logs_policy
├─ CreateLogGroup
├─ CreateLogStream
├─ PutLogEvents
└─ Resource: CloudWatch Logs
```

### IAM Instance Profile
```
aws_iam_instance_profile.ec2_profile
└─ Role: ec2_role
```

---

## Database (RDS) (3 resources)

### Security Group
```
aws_security_group.rds_sg
├─ Inbound: From EC2 on port 3306 (MySQL)
├─ Outbound: All traffic
└─ VPC: app_vpc
```

### DB Subnet Group
```
aws_db_subnet_group.app_db_subnet
├─ Subnets: private_subnet_1, private_subnet_2
└─ Availability Zones: us-east-1a, us-east-1b
```

### RDS Instance
```
aws_db_instance.app_db
├─ Engine: MySQL 8.0.35
├─ Instance Class: db.t3.micro
├─ Database Name: webapp_db
├─ Master Username: admin
├─ Master Password: (your choice)
├─ Storage: 20 GB
├─ Multi-AZ: Enabled
├─ Backup Retention: 7 days
├─ Publicly Accessible: No
├─ Subnet Group: app_db_subnet
├─ Security Group: rds_sg
└─ Skip Final Snapshot: true
```

---

## Storage (S3) (5 resources)

### S3 Bucket
```
aws_s3_bucket.app_bucket
├─ Name: simple-web-app-bucket-{account_id}
├─ Versioning: Enabled
├─ Encryption: AES-256
└─ Public Access: Blocked
```

### Bucket Versioning
```
aws_s3_bucket_versioning.app_bucket_versioning
└─ Status: Enabled
```

### Bucket Encryption
```
aws_s3_bucket_server_side_encryption_configuration.app_bucket_encryption
└─ Algorithm: AES256
```

### Public Access Block
```
aws_s3_bucket_public_access_block.app_bucket_public_block
├─ Block Public ACLs: true
├─ Block Public Policy: true
├─ Ignore Public ACLs: true
└─ Restrict Public Buckets: true
```

### Lifecycle Policy
```
aws_s3_bucket_lifecycle_configuration.app_bucket_lifecycle
├─ Rule: Delete old versions
└─ Retention: 30 days
```

---

## Data Sources (2)

### Availability Zones
```
data.aws_availability_zones.available
└─ State: available
```

### AWS Account ID
```
data.aws_caller_identity.current
└─ For S3 bucket naming
```

### Latest Ubuntu AMI
```
data.aws_ami.ubuntu
├─ Owner: Canonical (099720109477)
├─ Image: ubuntu-jammy-22.04-amd64-server
├─ Virtualization: HVM
└─ Most Recent: true
```

---

## Resource Dependency Map

```
Internet
  ↓
IGW ← VPC
  ↓
Public Subnets (2)
  ↓
ALB + ALB Security Group
  ↓
Target Group → Auto Scaling Group
  ↓
Launch Template
  ↓
├─ EC2 Instances (1-3)
│   ├─ EC2 Security Group
│   ├─ IAM Role + Policies
│   ├─ EC2 Instance Profile
│   ├─ User Data Script
│   └─ Private Subnets (2)
│
├─ RDS Database
│   ├─ DB Subnet Group
│   ├─ RDS Security Group
│   └─ Private Subnets (2)
│
└─ S3 Bucket
    ├─ Versioning
    ├─ Encryption
    ├─ Public Access Block
    └─ Lifecycle Policy

NAT Gateways (2)
  ├─ Elastic IPs (2)
  ├─ Public Subnets (2)
  └─ Route Tables - Private (2)
```

---

## Resource Counts by Type

| Type | Count | Purpose |
|------|-------|---------|
| VPC | 1 | Network container |
| Subnets | 4 | Public (2) + Private (2) |
| Security Groups | 3 | ALB, EC2, RDS |
| Internet Gateway | 1 | Public internet access |
| NAT Gateways | 2 | Private subnet internet |
| Elastic IPs | 2 | NAT Gateway IPs |
| Route Tables | 3 | Public (1) + Private (2) |
| Route Table Associations | 4 | Subnet routing |
| Application Load Balancer | 1 | Traffic distribution |
| Target Groups | 1 | ALB targets |
| Listeners | 1 | ALB port 80 |
| Launch Templates | 1 | EC2 configuration |
| Auto Scaling Groups | 1 | EC2 management |
| EC2 Instances | 1-3 | Application servers |
| IAM Roles | 1 | EC2 permissions |
| IAM Policies | 2 | S3 + CloudWatch |
| IAM Instance Profiles | 1 | EC2 role binding |
| RDS Instances | 1 | Database server |
| DB Subnet Groups | 1 | RDS networking |
| S3 Buckets | 1 | Object storage |
| S3 Versioning | 1 | Version management |
| S3 Encryption | 1 | Security |
| S3 Public Access Block | 1 | Access control |
| S3 Lifecycle Rules | 1 | Retention policy |
| **TOTAL** | **~40** | |

---

## Resource Costs (Estimated Monthly)

| Resource | Size | Cost/Month |
|----------|------|-----------|
| EC2 On-Demand | 2 × t3.micro | $10 |
| RDS | db.t3.micro Multi-AZ | $35 |
| Application Load Balancer | 1 × ALB | $16 |
| NAT Gateway | 2 × NAT | $45 |
| Data Transfer | Out of AWS | $0-10 |
| S3 Storage | Small | $1-5 |
| **TOTAL** | | **$100-120** |

**Note:** First 12 months may be free under AWS Free Tier (t3.micro eligible)

---

## Deployment Checklist

Resources will be created in this order:

- [ ] VPC
- [ ] Internet Gateway
- [ ] Subnets (4)
- [ ] Route Tables (3)
- [ ] Route Table Associations (4)
- [ ] Elastic IPs (2)
- [ ] NAT Gateways (2)
- [ ] Security Groups (3)
- [ ] RDS Subnet Group
- [ ] RDS Instance (takes 5-10 minutes)
- [ ] S3 Bucket + Configuration
- [ ] IAM Role + Policies + Instance Profile
- [ ] Launch Template
- [ ] Application Load Balancer
- [ ] Target Group
- [ ] ALB Listener
- [ ] Auto Scaling Group (creates 2 EC2 instances)
- [ ] EC2 Instances (takes 5 minutes each, total 10-15 minutes)

**Total Deployment Time:** 15-20 minutes

---

## Verification Commands

After deployment, verify resources with:

```bash
# VPC
aws ec2 describe-vpcs --filters "Name=cidr,Values=10.0.0.0/16"

# Subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Security Groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>"

# EC2 Instances
aws ec2 describe-instances

# Auto Scaling Group
aws autoscaling describe-auto-scaling-groups

# Load Balancer
aws elbv2 describe-load-balancers

# Target Health
aws elbv2 describe-target-health --target-group-arn <tg-arn>

# RDS Instance
aws rds describe-db-instances

# S3 Bucket
aws s3 ls

# IAM Roles
aws iam list-roles
```

---

## Cleanup

To remove all resources:

```bash
terraform destroy
```

This will delete:
- All EC2 instances (Auto Scaling Group)
- Application Load Balancer
- RDS Database
- S3 Bucket
- VPC and all subnets
- Security Groups
- IAM Roles and Policies
- All associated resources

**Note:** Some resources may take a few minutes to delete.

---

## Resource Tags

All resources are tagged with:
```
Environment = "dev" (or your environment)
Project = "web-app"
ManagedBy = "Terraform"
```

Use these tags to track resources in AWS Console:
```bash
aws ec2 describe-instances --filters "Name=tag:Project,Values=web-app"
```

---

## Next Steps

1. Review this inventory
2. Proceed to [QUICKSTART.md](./QUICKSTART.md)
3. Deploy with `terraform apply`
4. Monitor resource creation in AWS Console
5. Verify all resources deployed correctly

---

**Last Updated:** December 2024
