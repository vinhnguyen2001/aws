# BoostUp AWS Infrastructure - Deployment Guide

## Architecture Overview

This infrastructure creates a complete AWS environment with:
- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **RDS MySQL**: Database in private subnet for data storage
- **EC2 Instance**: Backend API server in public subnet
- **S3**: Static website hosting for frontend

## Real Database Integration

The website now includes **real database interaction**:
- Messages are stored in RDS MySQL database
- EC2 instance runs a Node.js API server
- Frontend communicates with the API to store/retrieve data

## Prerequisites

1. **AWS CLI configured** with proper credentials
2. **Terraform installed** (v1.0+)
3. **SSH Key Pair created** in AWS EC2
   ```bash
   aws ec2 create-key-pair --key-name boostup-key --query 'KeyMaterial' --output text > boostup-key.pem
   chmod 400 boostup-key.pem
   ```

## Deployment Steps

### 1. Update Configuration

Edit `environments/dev/terraform.tfvars` and update:
```hcl
ec2_key_name = "your-key-pair-name"  # Replace with your actual key pair name
bucket_name  = "your-unique-bucket-name"  # Must be globally unique
```

### 2. Initialize Terraform

```bash
cd environments/dev
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- VPC with subnets, route tables, NAT gateway
- RDS MySQL database
- EC2 instance with Node.js API server
- S3 bucket with website files

### 5. Get the API Endpoint

After deployment completes, note the outputs:
```bash
terraform output
```

You'll see:
```
api_endpoint = "http://XX.XX.XX.XX:3000"
api_server_public_ip = "XX.XX.XX.XX"
website_url = "your-bucket.s3-website-us-east-1.amazonaws.com"
```

### 6. Update Frontend Configuration

**IMPORTANT**: Update the API endpoint in the website:

1. Open `source/script.js`
2. Replace the first line:
   ```javascript
   const API_ENDPOINT = 'http://YOUR_API_IP:3000';
   ```
   with your actual API server IP from the terraform output

3. Re-upload to S3:
   ```bash
   terraform apply  # This will update the S3 files
   ```

### 7. Access the Website

Open your browser and go to the S3 website URL from the terraform output.

## Testing the Database Integration

1. **Test Connection**: Click "Test RDS Connection" to verify API → RDS connection
2. **Save Message**: Enter a message and click "Save to Database"
3. **Load Messages**: Click "Load Messages" to view all stored messages from RDS

## Architecture Flow

```
User Browser
    ↓
S3 Static Website (Frontend)
    ↓ (HTTP API Calls)
EC2 Instance (Node.js API Server)
    ↓ (MySQL Connection)
RDS MySQL Database (Private Subnet)
```

## SSH into API Server (Optional)

To check the API server logs or status:

```bash
ssh -i boostup-key.pem ec2-user@YOUR_API_IP

# Check API service status
sudo systemctl status boostup-api

# View logs
sudo journalctl -u boostup-api -f
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

## Troubleshooting

### API Connection Failed
- Ensure EC2 instance is running: Check AWS Console → EC2
- Check security group allows port 3000
- Wait 2-3 minutes after deployment for the API server to fully initialize

### Database Connection Error
- Verify RDS security group allows traffic from EC2 (already configured)
- Check RDS endpoint is correct in the API server configuration
- Review API server logs via SSH

### S3 Website Not Loading
- Verify bucket policy allows public read access
- Check website configuration is enabled
- Ensure bucket name is globally unique

## Features

- ✅ Real database storage (not simulated)
- ✅ RESTful API backend
- ✅ Secure VPC architecture
- ✅ Multi-AZ capable
- ✅ Auto-scaling storage
- ✅ 7-day backup retention
- ✅ Infrastructure as Code with Terraform

## Costs Estimate

- **EC2 t2.micro**: ~$8/month (free tier eligible)
- **RDS db.t3.micro**: ~$15/month (free tier eligible)
- **S3**: <$1/month for small websites
- **Data Transfer**: Varies by usage

**Note**: Use free tier if available. Remember to destroy resources when not in use.
