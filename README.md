# 🏠 Homelab Infrastructure

**⚠️ Work in progress ⚠️**

This repository contains the **Infrastructure as Code (IaC)** setup for my personal homelab.

It uses:

- **Ansible** for configuring and deploying services inside the VMs
- **Terraform** for provisioning virtual machines and networks on Proxmox
- **Proxmox VE** for virtualization and container management

## Setup

### Prerequisites

Before running any commands, ensure you have the following tools installed on your local machine:

- **Terraform**
- **Ansible**

### Required Configuration Files

**⚠️ All variable files must be properly configured before running any commands**

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

### VM Configuration

The `.env` file supports the following variables for configuring your local VMs:

- `LOCAL_NUMBER_OF_VMS` - Number of VMs to create
- `LOCAL_STARTING_IP_ADDRESS` - Starting IP address with subnet (e.g., `192.168.10.20/24`)
- `LOCAL_STARTING_VM_ID` - Starting VM ID for Proxmox
- `LOCAL_VM_NAME_PREFIX` - Prefix for VM names (default: `local-vm`)
- `LOCAL_VM_CORES` - Number of CPU cores per VM (default: `2`)
- `LOCAL_VM_MEMORY` - Memory in MB per VM (default: `4096`)

Example configuration:
```bash
LOCAL_NUMBER_OF_VMS=3
LOCAL_STARTING_IP_ADDRESS=192.168.10.20/24
LOCAL_STARTING_VM_ID=300
LOCAL_VM_NAME_PREFIX=docker-host
LOCAL_VM_CORES=4
LOCAL_VM_MEMORY=8192
```

This will create 3 VMs named `docker-host-01`, `docker-host-02`, `docker-host-03` with 4 cores and 8GB RAM each.

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
4. **Create cloud-init template in Proxmox**:
   ```bash
   make create-cloudinit
   ```
5. **Initialize Terraform**:
   ```bash
   make terraform-init
   ```
6. **Verify the upcomming changes in Terraform**:
   ```bash
   make terraform-plan
   ```
   **This step is crucial as it also generates the execution plan that determines how many VMs will be created and their configuration.**
7. **Make the changes in Proxmox**:
   ```bash
   make terraform-apply
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
