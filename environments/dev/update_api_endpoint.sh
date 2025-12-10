#!/bin/bash

# Script to update the API endpoint in the frontend after terraform apply
# Usage: ./update_api_endpoint.sh

echo "=================================="
echo "BoostUp API Endpoint Configuration"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "terraform.tfvars" ]; then
    echo "Error: This script should be run from the environments/dev directory"
    exit 1
fi

# Get the API endpoint from terraform output
echo "Getting API endpoint from Terraform output..."
API_ENDPOINT=$(terraform output -raw api_endpoint 2>/dev/null)

if [ -z "$API_ENDPOINT" ]; then
    echo "Error: Could not get API endpoint. Make sure you've run 'terraform apply' first."
    exit 1
fi

echo "API Endpoint: $API_ENDPOINT"
echo ""

# Update the script.js file
SCRIPT_FILE="../../source/script.js"

if [ ! -f "$SCRIPT_FILE" ]; then
    echo "Error: script.js not found at $SCRIPT_FILE"
    exit 1
fi

# Backup the original file
cp "$SCRIPT_FILE" "$SCRIPT_FILE.backup"

# Replace the API endpoint
sed -i.tmp "s|const API_ENDPOINT = '.*';|const API_ENDPOINT = '$API_ENDPOINT';|g" "$SCRIPT_FILE"
rm "$SCRIPT_FILE.tmp" 2>/dev/null

echo "✓ Updated API endpoint in script.js"
echo ""
echo "Now uploading updated website to S3..."
terraform apply -auto-approve -target=module.s3

echo ""
echo "=================================="
echo "✓ Configuration Complete!"
echo "=================================="
echo ""
echo "Your website is now configured to use the real API backend."
echo ""
echo "Website URL: $(terraform output -raw website_url)"
echo "API Endpoint: $API_ENDPOINT"
echo ""
echo "Test your website by:"
echo "1. Opening the website URL in your browser"
echo "2. Click 'Test RDS Connection'"
echo "3. Try saving a message to the database"
echo ""
