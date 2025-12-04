# Architecture Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           Internet                              │
└─────────────────────────────────────┬───────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    │ AWS Region: us-east-1             │
                    │                                   │
        ┌───────────▼────────────────────────────┐      │
        │      Application Load Balancer (ALB)   │      │
        │   - DNS: app-alb.elb.amazonaws.com     │      │
        │   - Ports: 80 (HTTP)                   │      │
        │   - Health Checks: /health             │      │
        └───────────┬────────────────────────-┬--┘      │
                    │                         │         │
        ┌───────────▼─────────┐    ┌──────────▼───-──┐  │
        │ Public Subnet 1     │    │ Public Subnet 2 │  │
        │ 10.0.1.0/24         │    │ 10.0.2.0/24     │  │
        │ AZ: us-east-1a      │    │ AZ: us-east-1b  │  │
        │                     │    │                 │  │
        │ ┌─────────────────┐ │    │ ┌─────────────┐ │  │
        │ │  NAT Gateway 1  │ │    │ │ NAT Gateway2│ │  │
        │ │  EIP: xx.xx...  │ │    │ │ EIP: xx.xx..│ │  │
        │ └────────┬────────┘ │    │ └────────┬────┘ │  │
        └─────────┼──────────-┘    └─────────┼─────-─┘  │
                  │                         │           │
        ┌─────────▼──────────┐    ┌────────▼─────-─┐  │
        │ Private Subnet 1   │    │ Private Subnet2│  │
        │ 10.0.10.0/24       │    │ 10.0.11.0/24   │  │
        │                    │    │                │  │
        │ ┌────────────────┐ │    │ ┌────────────┐ │  │
        │ │ EC2 Instance 1 │ │    │ │ EC2 Inst 2 │ │  │
        │ │ (Auto Scaling) │ │    │ │ (Auto Scal)│ │  │
        │ │ Node.js App    │ │    │ │ Node.js    │ │  │
        │ └────────┬───────┘ │    │ └───────┬───-┘ │  │
        │          │         │    │         │      │  │
        │ ┌────────▼───────────────────────▼───┐   │  │
        │ │  Security Group: EC2 (Port 80)     │   │  │
        │ │  Inbound: From ALB on port 80      │   │  │
        │ └────────────────────────────────────┘   │  │
        └────────────────────────────────────────┘  │
                          │                         │
        ┌─────────────────▼────────────────────┐    │
        │ RDS MySQL Database                    │    │
        │ - Engine: MySQL 8.0.35               │    │
        │ - Instance: db.t3.micro              │    │
        │ - Multi-AZ: Enabled                  │    │
        │ - Endpoint: <endpoint>:3306          │    │
        │ - Database: webapp_db                │    │
        │                                      │    │
        │ Private Subnets: 10.0.10.0 - 10.0.11│    │
        │ Security: Only from EC2 (Port 3306) │    │
        └──────────────────────────────────────┘    │
                                                    │
        ┌──────────────────────────────────────┐    │
        │ S3 Bucket: simple-web-app-bucket     │    │
        │ - Versioning: Enabled                │    │
        │ - Encryption: AES256                 │    │
        │ - Public Access: Blocked             │    │
        │ - Lifecycle: Delete old versions     │    │
        │                                      │    │
        │ Access: From EC2 via IAM Role        │    │
        └──────────────────────────────────────┘    │
        │                                           │
        └───────────────────────────────────────────┘
```

## Data Flow

### 1. User Request to Application
```
User Browser
    ↓
Internet (HTTP)
    ↓
ALB (Port 80)
    ↓ (Routes to target group)
Auto Scaling Group
    ↓ (Health check /health)
EC2 Instance (Node.js)
    ↓ (Queries database)
RDS MySQL
    ↓ (Returns visitor count)
EC2 Instance (Renders HTML)
    ↓ (Returns response)
ALB
    ↓ (HTTP response)
User Browser (Displays page)
```

### 2. Application to Storage
```
EC2 Instance (Node.js)
    ↓ (IAM Role permissions)
S3 Bucket (via AWS SDK)
    ↓ (Put/Get operations)
Application Data
```

### 3. Database Connections
```
EC2 Security Group (10.0.10.0 - 10.0.11.0)
    ↓ (Port 3306)
RDS Security Group
    ↓ (MySQL protocol)
RDS Database (Multi-AZ)
    ↓
Primary Database (AZ-1)
    ↓ (Synchronous replication)
Standby Database (AZ-2)
```

## AWS Services and Their Roles

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **VPC** | Network isolation | CIDR: 10.0.0.0/16 |
| **EC2** | Application compute | t3.micro, Auto Scaling 1-3 |
| **Auto Scaling Group** | High availability | Min: 1, Max: 3, Desired: 2 |
| **RDS** | Database layer | MySQL 8.0.35, Multi-AZ |
| **S3** | Object storage | Versioning + Encryption |
| **ALB** | Load balancing | Health checks on / |
| **Security Groups** | Network access | Least privilege rules |
| **IAM Roles** | Service permissions | S3, CloudWatch Logs |
| **NAT Gateway** | Private subnet internet | 2 per subnet for HA |

## High Availability Design

### 1. **Multi-AZ Deployment**
- EC2 instances spread across 2 availability zones
- RDS database with Multi-AZ failover
- NAT Gateways in each AZ
- ALB distributes across subnets

### 2. **Auto Scaling**
- Minimum 1 instance (can scale to 3)
- ALB health checks every 30 seconds
- Unhealthy instances replaced automatically

### 3. **Database Redundancy**
- Primary RDS instance in AZ-1
- Standby instance in AZ-2
- Synchronous replication
- Automatic failover in < 2 minutes

### 4. **Network Redundancy**
- Multiple subnets
- NAT gateways in each zone
- Internet Gateway for public access

## Security Architecture

### Network Security
```
┌─ Internet
│
├─ ALB Security Group
│  └─ Allow: 0.0.0.0/0:80 (HTTP)
│  └─ Allow: 0.0.0.0/0:443 (HTTPS - future)
│
├─ EC2 Security Group
│  └─ Allow: From ALB on port 80
│  └─ Deny: All other inbound
│  └─ Allow: To RDS on port 3306
│  └─ Allow: To S3 via HTTPS
│
└─ RDS Security Group
   └─ Allow: From EC2 on port 3306
   └─ Deny: All other inbound
```

### IAM Security
```
EC2 Instance Role
├─ S3 Permissions
│  ├─ GetObject
│  ├─ PutObject
│  └─ ListBucket
│
└─ CloudWatch Logs
   ├─ CreateLogGroup
   ├─ CreateLogStream
   └─ PutLogEvents
```

### Data Protection
- S3: AES-256 encryption at rest
- RDS: Encryption at rest (optional)
- Transit: Security group restrictions
- Access: IAM roles (no hardcoded credentials)

## Cost Optimization

### Estimated Monthly Costs (us-east-1)

| Service | Configuration | Estimated Cost |
|---------|---------------|-----------------|
| EC2 | 2 × t3.micro | $10-15 |
| RDS | db.t3.micro Multi-AZ | $30-40 |
| ALB | Standard | $16-20 |
| NAT Gateway | 2 instances | $32-45 |
| S3 | Storage + requests | $1-5 |
| Data Transfer | Out of AWS | $0-10 |
| **Total** | | **$90-135** |

### Cost Reduction Options
1. Use single NAT Gateway ($45 → $22.50)
2. Reduce Auto Scaling Group size (2 → 1)
3. Use RDS Single-AZ (saves 50%)
4. Use t3.nano instances (saves 50%)

## Scaling Strategy

### Horizontal Scaling (EC2)
- Increase `desired_capacity` in Auto Scaling Group
- ALB automatically distributes traffic
- New instances initialize with user_data script

### Vertical Scaling (RDS)
- Change `instance_class` from db.t3.micro
- Options: db.t3.small, db.t3.medium, etc.
- Requires 1-5 minute downtime

### Database Scaling
- Add read replicas for read-heavy workloads
- Implement caching layer (ElastiCache)
- Shard data across multiple databases

## Disaster Recovery

### RTO/RPO Targets
- **RTO (Recovery Time Objective)**: < 2 minutes
- **RPO (Recovery Point Objective)**: < 1 minute

### Backup Strategy
```
- RDS: Automated snapshots daily
- S3: Versioning enabled (30-day retention)
- EC2: Auto Scaling replace failed instances
- Configuration: Terraform state file (backup separately)
```

### Disaster Recovery Procedure
1. RDS Failover (automatic - 2 min)
2. EC2 replacement (automatic - 5 min)
3. Terraform state recovery (manual - 1 hour)
4. Application restart (automatic - 30 sec)

---

*Last Updated: December 2024*
