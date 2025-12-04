terraform-aws-app/
├── modules/                    # Reusable modules
│   ├── networking/            # VPC, Subnets, IGW, NAT
│   ├── compute/               # EC2, ASG, Launch Template
│   ├── database/              # RDS MySQL
│   ├── storage/               # S3 buckets
│   ├── dns/                   # Route53
│   └── loadbalancer/          # ALB (optional)
├── environments/              # Environment-specific configs
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   ├── staging/
│   └── prod/
├── scripts/                   # Helper scripts
│   └── user_data.sh
├── .gitignore
└── README.md