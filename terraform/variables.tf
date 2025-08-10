variable "PROXMOX_VM_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
}

variable "VM_USER" {
  type        = string
  description = "Username for VM access"
  default     = "ubuntu"
}

variable "LOCAL_VMS" {
  type = map(object({
    name       = string
    vm_id      = number
    ip_address = string
    cores      = optional(number, 2)
    memory     = optional(number, 4096)
    disk_size  = optional(number, 32)  # Disk size in GB
  }))
  description = "Map of Docker VMs with their configurations"
  default     = {}
}