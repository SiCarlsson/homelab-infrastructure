# Makefile for Terraform operations with environment variables
.PHONY: plan apply destroy init validate create-cloudinit

# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

###
# Proxmox commands
###
# Create cloud-init template
create-cloudinit:
	./scripts/create-cloud-init-template.sh

###
# Terraform commands
###
# Initialize Terraform
init:
	cd terraform && terraform init

# Plan Terraform changes
plan:
	cd terraform && terraform plan

# Apply Terraform changes
apply:
	cd terraform && terraform apply

# Destroy Terraform infrastructure
destroy:
	cd terraform && terraform destroy

# Validate Terraform configuration
validate:
	cd terraform && terraform validate
