.PHONY: help init plan apply destroy output validate fmt clean

TF_DIR := terraform
TF := terraform -chdir=$(TF_DIR)

help:
	@echo "Available commands:"
	@echo "  make init       - Initialize Terraform"
	@echo "  make plan       - Plan the deployment"
	@echo "  make apply      - Apply the configuration"
	@echo "  make destroy    - Destroy all resources"
	@echo "  make output     - Show outputs"
	@echo "  make validate   - Validate Terraform files"
	@echo "  make fmt        - Format Terraform files"
	@echo "  make clean      - Clean up Terraform files"
	@echo "  make status     - Show infrastructure status"
	@echo "  make logs       - Show application logs"

init:
	@echo "Initializing Terraform..."
	$(TF) init

validate:
	@echo "Validating Terraform configuration..."
	$(TF) validate

fmt:
	@echo "Formatting Terraform files..."
	$(TF) fmt -recursive

plan:
	@echo "Planning deployment..."
	$(TF) plan -out=tfplan

apply: plan
	@echo "Applying configuration..."
	$(TF) apply tfplan

destroy:
	@echo "Destroying infrastructure..."
	$(TF) destroy

output:
	@echo "Infrastructure outputs:"
	$(TF) output

status:
	@echo "Getting EC2 instances status..."
	aws ec2 describe-instances \
		--query 'Reservations[].Instances[].[InstanceId,State.Name,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
		--output table

logs:
	@echo "Tailing application logs..."
	aws logs tail --follow --format short 2>/dev/null || echo "No logs available yet"

clean:
	@echo "Cleaning up..."
	rm -rf $(TF_DIR)/.terraform
	rm -f $(TF_DIR)/tfplan
	rm -f $(TF_DIR)/.terraform.lock.hcl

.DEFAULT_GOAL := help
