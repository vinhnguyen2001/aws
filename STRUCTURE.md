├── versions.tf             # Global configuration for Terraform and Provider versions
|
├── modules/                # Reusable Infrastructure Blueprints
│   ├── vpc/                # 1. Network Foundation (VPC, Subnets, NAT GW, Routing)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/                # 2. Data Tier (RDS Instance, DB Subnet Group)
│   │   └── ... 
│   │
│   ├── compute/      # 3. Application Tier (EC2, ALB, Target Groups, Security Groups)
│   │   └── ... 
│   │
│   └── s3/                 # 4. Frontend Tier (S3 Bucket, Website Config, Policy)
│       └── ... 
│
├── environments/           # Deployment Root Modules (Where 'terraform apply' is run)
│   ├── dev/                # Development Environment
│   │   ├── main.tf         # Calls all modules with DEV-specific variables
│   │   └── backend.tf      # Remote State configuration (e.g., S3 Backend)
│   │
│   └── prod/               # Production Environment
│       └── main.tf
│
└── source/        # Static Website Files
    ├── index.html
    ├── error.html
    └── assets/
        └── styles.css