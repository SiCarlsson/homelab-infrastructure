# This file creates the Proxmox Infrastructure using Terraform
# It requires the Proxmox provider and the necessary credentials to be set up

resource "proxmox_virtual_environment_vm" "local_vms" {
  for_each = var.LOCAL_VMS

  name      = each.value.name
  vm_id     = each.value.vm_id
  node_name = "pve-1"

  agent {
    enabled = false
  }

  clone {
    vm_id = 900
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  initialization {
    datastore_id = "nvme"

    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = "192.168.10.1"
      }
    }

    dns {
      servers = ["192.168.10.1", "8.8.8.8"]
    }

    user_account {
      username = "ubuntu"
      keys     = [var.PROXMOX_VM_SSH_PUBLIC_KEY]
    }
  }

  started         = true
  stop_on_destroy = true
}
