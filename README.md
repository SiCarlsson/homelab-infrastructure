# 🏠 Homelab Infrastructure

This repository contains the **Infrastructure as Code (IaC)** setup for my personal homelab. It uses:

- **Ansible** for configuring and deploying services inside the VMs
- **Terraform** for provisioning virtual machines and networks on Proxmox

> ⚠️ Work in progress — I'm learning Terraform and Ansible, and gradually automating more of my setup.

## Setup

### Environment Configuration
1. Copy `.env.example` to `.env` and fill in your server details
2. MAke any changes necessary to suit your infrastructure
3. Generate the Ansible hosts file from `.env`:
   ```bash
   chmod +x ./generate-hosts.sh && ./generate-hosts.sh
   ```
4. The generated `ansible/inventory/hosts` file will contain your actual server information

This approach keeps sensitive server information out of the public repository while maintaining a clean template structure.
