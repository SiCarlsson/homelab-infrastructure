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
    disk_size  = optional(number, 32)
  }))
  description = "Map of Local VMs with their configurations"
  default     = {}
}

variable "PUBLIC_VMS" {
  type = map(object({
    name       = string
    vm_id      = number
    ip_address = string
    cores      = optional(number, 2)
    memory     = optional(number, 4096)
    disk_size  = optional(number, 32)
  }))
  description = "Map of Public VMs with their configurations"
  default     = {}
}
