# 🏠 Homelab Infrastructure

This repository contains the **Infrastructure as Code (IaC)** setup for my personal homelab. It uses:

- **Ansible** for configuring and deploying services inside the VMs
- **Terraform** for provisioning virtual machines and networks on Proxmox

> ⚠️ Work in progress — I'm learning Terraform and Ansible, and gradually automating more of my setup.

## Setup

### Environment Configuration
1. Copy `.env.example` to `.env` and fill in your server details
2. Generate the Ansible inventory from `.env`:
   ```bash
   chmod +x ./generate-inventory.sh && ./generate-inventory.sh
   ```
3. The generated `ansible/inventory/hosts` file will contain your actual server information

This approach keeps sensitive server information out of the public repository while maintaining a clean template structure. Only one virtual machine is supported as of now.
