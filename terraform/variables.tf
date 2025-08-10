variable "PROXMOX_VM_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
}

variable "LOCAL_DOCKER_VM_NAME" {
  type        = string
  description = "Name of the local Docker VM"
}

variable "LOCAL_DOCKER_VM_IP_ADDRESS" {
  type        = string
  description = "IP address for the local Docker VM"
}