# This file creates the Proxmox Infrastructure using Terraform
# It requires the Proxmox provider and the necessary credentials to be set up

resource "proxmox_vm_qemu" "vm1" {
  name   = "vm1"
  description = "Ubuntu Server"
  vmid = "301"
  target_node = "M900"


  clone = "ubuntu-22.04-template"
  cpu {
    cores = 2
    sockets = 1
    type = "host"
  }
  memory = 2048
}
