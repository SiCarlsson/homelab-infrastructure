# This file contains the Terraform provider configuration

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.81"
    }
  }
}

variable "PROXMOX_API_URL" {
  type        = string
  description = "Proxmox API URL"
}

variable "PROXMOX_API_TOKEN_ID" {
  type        = string
  description = "Proxmox API token id"
  sensitive   = true
}

variable "PROXMOX_API_TOKEN_SECRET" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}

provider "proxmox" {
  endpoint  = var.PROXMOX_API_URL
  api_token = "${var.PROXMOX_API_TOKEN_ID}=${var.PROXMOX_API_TOKEN_SECRET}"
  insecure  = true
}
