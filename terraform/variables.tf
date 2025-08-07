variable "PROXMOX_VM_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
}

variable "NETWORK_VM_NAME" {
  type        = string
  description = "Name of the network VM"
}

variable "NETWORK_VM_IP_ADDRESS" {
  type        = string
  description = "IP address for the network VM"
}