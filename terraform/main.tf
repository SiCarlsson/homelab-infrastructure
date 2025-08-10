# This file creates the Proxmox Infrastructure using Terraform
# It requires the Proxmox provider and the necessary credentials to be set up

resource "proxmox_virtual_environment_vm" "network_vm" {
  name      = var.LOCAL_DOCKER_VM_NAME
  vm_id     = 300
  node_name = "pve-1"

  agent {
    enabled = false
  }

  clone {
    vm_id = 900
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  initialization {
    datastore_id = "nvme"

    ip_config {
      ipv4 {
        address = var.LOCAL_DOCKER_VM_IP_ADDRESS
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

  started = true
  stop_on_destroy = true
}
