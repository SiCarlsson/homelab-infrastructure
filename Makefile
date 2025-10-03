# Makefile for Terraform operations with environment variables
.PHONY: terraform-plan terraform-apply terraform-destroy terraform-init terraform-validate create-cloudinit create-ssh-to-pve init-scripts ansible-generate-hosts ansible-install-docker ansible-ping

# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

###
# Quick commands
###
quick-init:
	$(MAKE) init-scripts
	$(MAKE) create-ssh-to-pve
	$(MAKE) create-cloudinit
	$(MAKE) terraform-init

quick-terraform:
	./scripts/create-vms-tfvars.sh
	./scripts/create-ansible-hosts.sh
	cd terraform && terraform apply -auto-approve

quick-ansible:
	$(MAKE) ansible-install-docker
	$(MAKE) ansible-install-traefik
	$(MAKE) ansible-install-cloudflare-ddns

quick-up-all:
	$(MAKE) quick-init
	$(MAKE) quick-terraform
	$(MAKE) quick-ansible


###
# Setup commands
###
# Make all scripts executable
init-scripts:
	chmod +x scripts/*.sh


###
# Proxmox commands
###
# Establish SSH connection to Proxmox host
create-ssh-to-pve:
	./scripts/create-ssh-to-pve.sh

# Create cloud-init template
create-cloudinit:
	./scripts/create-cloud-init-template.sh


###
# Terraform commands
###
terraform-init:
	cd terraform && terraform init

terraform-plan:
	./scripts/create-vms-tfvars.sh
	cd terraform && terraform plan

terraform-apply:
	./scripts/create-ansible-hosts.sh
	cd terraform && terraform apply -auto-approve

terraform-destroy:
	cd terraform && terraform destroy -auto-approve

terraform-validate:
	cd terraform && terraform validate


###
# Ansible commands
###
ansible-generate-hosts:
	./scripts/create-ansible-hosts.sh

ansible-ping:
	ansible -i ansible/inventory/hosts.yml all -m ping

ansible-install-docker:
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/docker-setup.yml

ansible-install-traefik:
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/traefik-setup.yml

ansible-install-cloudflare-ddns:
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/cloudflare-ddns-setup.yml \
		-e cloudflare_api_token="$(CLOUDFLARE_API_TOKEN)" \
		-e cloudflare_zone="$(CLOUDFLARE_ZONE)" \
		$(if $(CLOUDFLARE_SUBDOMAIN),-e cloudflare_subdomain="$(CLOUDFLARE_SUBDOMAIN)",)
