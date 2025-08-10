variable "PROXMOX_VM_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for VM access"
  sensitive   = true
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