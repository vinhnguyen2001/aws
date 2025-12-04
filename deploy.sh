#!/bin/bash

# Quick Start Deployment Script
# This script automates the deployment process for the web application

set -e

echo "=========================================="
echo "AWS Web Application Deployment Script"
echo "=========================================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    echo "Install from: https://www.terraform.io/downloads.html"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    echo "Install from: https://aws.amazon.com/cli/"
    exit 1
fi

if [ -z "$AWS_PROFILE" ] && [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "❌ AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

echo "✅ All prerequisites met"
echo ""

# Navigate to terraform directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

cd "$TERRAFORM_DIR"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo "⚠️  terraform.tfvars not found"
    echo "Creating from template..."
    cp terraform.tfvars.example terraform.tfvars
    echo "⚠️  Please edit terraform.tfvars with your desired values"
    echo "Especially: db_password, s3_bucket_name"
    exit 1
fi

# Plan the deployment
echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
echo "=========================================="
echo "Review the planned changes above"
echo "=========================================="
read -p "Do you want to proceed with deployment? (yes/no): " -r REPLY

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Apply the configuration
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Display outputs
echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "📊 Infrastructure Details:"
echo ""
terraform output
echo ""
echo "🌐 Access your application at:"
echo "$(terraform output -raw app_url)"
echo ""
echo "💾 Remember to:"
echo "1. Note the database endpoint"
echo "2. Save your RDS password securely"
echo "3. Monitor costs in AWS Console"
echo ""
echo "🗑️  To destroy all resources: terraform destroy"
echo ""
