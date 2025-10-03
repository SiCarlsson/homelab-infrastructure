# 🏠 Homelab Infrastructure

This repository contains the **Infrastructure as Code (IaC)** setup for my personal homelab.

It uses:

- **Proxmox VE** for virtualization and container management.
- **Ansible** for configuring and deploying services inside the VMs.
- **Terraform** for provisioning virtual machines and networks on Proxmox.

## Self-hosted services

- **Cloudflare DDNS**
  - Handles changes of my personal IP-address at home. Simplifies usage of VPNs and remote access to services.
- **Traefik**
  - Reverse proxy and load balancer that automatically routes traffic to services. Also provides a web dashboard for monitoring.

## Setup

### Prerequisites

Before running any commands, ensure you have the following tools installed on your local machine:

- **Terraform**
- **Ansible**

**NOTE:** This repository is designed for single-node Proxmox VE environments only.

### Required Configuration Files

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

2. **Initial setup and preparation**:

   ```bash
   make quick-init
   ```

   This will make scripts executable, set up SSH access to Proxmox, create cloud-init template, and initialize Terraform.

3. **Create infrastructure**:

   ```bash
   make quick-terraform
   ```

   This will generate VM configuration files, apply Terraform changes to create VMs, and generate Ansible hosts inventory.

4. **Install services**:
   ```bash
   make quick-ansible
   ```
   This will install Docker, Traefik reverse proxy, and Cloudflare DDNS service on all VMs.

> **Note:** If you prefer more granular control, see the individual commands in the [Available Commands](#available-commands) section below.

## Available Commands

### Quick Commands (Automation)

- `make quick-init` - Run all initial setup steps (init-scripts, create-ssh-to-pve, create-cloudinit, terraform-init).
- `make quick-terraform` - Generate configuration files and apply Terraform changes automatically.
- `make quick-ansible` - Install all services (Docker, Traefik, Cloudflare DDNS) on all hosts.
- `make quick-up-all` - Complete setup from scratch (runs quick-init, quick-terraform, quick-ansible).

### Setup Commands

- `make init-scripts` - Make all script files executable.

### Proxmox Commands

- `make create-ssh-to-pve` - Set up SSH access to Proxmox host.
- `make create-cloudinit` - Create cloud-init template on Proxmox.

### Terraform Commands

- `make terraform-init` - Initialize Terraform working directory.
- `make terraform-plan` - Show planned Terraform changes and generate VM configuration file.
- `make terraform-apply` - Apply Terraform changes.
- `make terraform-destroy` - Destroy Terraform-managed infrastructure.
- `make terraform-validate` - Validate Terraform configuration.

### Ansible Commands

- `make ansible-generate-hosts` - Generate Ansible hosts inventory file from Terraform state.
- `make ansible-ping` - Test connectivity to all hosts in the inventory.
- `make ansible-install-docker` - Install and configure Docker on all hosts using Ansible playbook.
- `make ansible-install-traefik` - Install and configure Traefik reverse proxy on all hosts.
- `make ansible-install-cloudflare-ddns` - Install and configure Cloudflare DDNS service on all hosts.
