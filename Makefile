# Makefile for Terraform operations with environment variables
.PHONY: plan apply destroy init

# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

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
