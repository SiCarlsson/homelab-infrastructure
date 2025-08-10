# 🏠 Homelab Infrastructure

**⚠️ Work in progress**

This repository contains the **Infrastructure as Code (IaC)** setup for my personal homelab. 

It uses:
- **Ansible** for configuring and deploying services inside the VMs
- **Terraform** for provisioning virtual machines and networks on Proxmox

## Setup

### Prerequisites

Before running any commands, ensure you have the following tools installed:
- **Terraform**
- **Ansible**

### Required Configuration Files

**⚠️ All variable files must be properly configured before running any commands:**

1. **Environment Variables** - Copy and configure the main environment file:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your specific values.

2. **Terraform Credentials** - Copy and configure Terraform credentials:
   ```bash
   cp terraform/credentials.auto.tfvars.example terraform/credentials.auto.tfvars
   ```
   Edit `terraform/credentials.auto.tfvars` with your Proxmox API credentials.

### Initial Setup Steps

1. **Configure all variable files** (see sections above)
2. **Make scripts executable**:
   ```bash
   make init-scripts
   ```
3. **Set up SSH access to Proxmox**:
   ```bash
   make create-ssh-to-pve
   ```
4. **Create cloud-init template**:
   ```bash
   make create-cloudinit
   ```
5. **Initialize Terraform**:
   ```bash
   make terraform-init
   ```

## Available Commands

### Setup Commands
- `make init-scripts` - Make all script files executable

### Proxmox Commands
- `make create-ssh-to-pve` - Set up SSH access to Proxmox host
- `make create-cloudinit` - Create cloud-init template on Proxmox

### Terraform Commands
- `make terraform-init` - Initialize Terraform working directory
- `make terraform-plan` - Show planned Terraform changes
- `make terraform-apply` - Apply Terraform changes
- `make terraform-destroy` - Destroy Terraform-managed infrastructure
- `make terraform-validate` - Validate Terraform configuration
