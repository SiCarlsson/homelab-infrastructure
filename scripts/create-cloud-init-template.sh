#!/bin/bash
# Cloud-Init Template Creator for Proxmox
# This script creates an Ubuntu cloud-init template that your Terraform can use

GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

# Use environment variables with defaults (loaded by Makefile from .env)
iso_file_name="${ISO_FILE_NAME:-noble-server-cloudimg-amd64.img}"
iso_directory="${ISO_DIRECTORY:-./iso/}"
iso_url="${ISO_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"

template_name="${TEMPLATE_NAME:-ubuntu-cloud-template}"
template_id="${TEMPLATE_ID:-901}"
proxmox_host_name="${PROXMOX_HOST_NAME:-pve-1}"
proxmox_host_ip="${PROXMOX_HOST_IP:-192.168.10.10}"
proxmox_host_username="${PROXMOX_USERNAME:-root}"
proxmox_storage_name="${PROXMOX_STORAGE_NAME:-nvme}"


echo -e "${BLUE}Starting cloud-init template creation process...${RESET}"

ssh -o Compression=no -o TCPKeepAlive=yes $proxmox_host_username@$proxmox_host_ip << EOF
export GREEN='\033[32m'
export BLUE='\033[34m'
export RED='\033[31m'
export RESET='\033[0m'

export iso_file_name="$iso_file_name"
export iso_directory="$iso_directory"
export iso_url="$iso_url"
export template_name="$template_name"
export template_id="$template_id"
export proxmox_storage_name="$proxmox_storage_name"


mkdir -p "$iso_directory"
cd "$iso_directory"

if [ ! -f "$iso_file_name" ]; then
  echo -e "${BLUE}Downloading ISO file: $iso_file_name from $iso_url${RESET}"
  curl -L -o "$iso_file_name" "$iso_url"
  echo -e "${GREEN}Download completed.${RESET}"
else
  echo -e "${GREEN}ISO file already exists: $iso_file_name${RESET}"
fi

if qm status $template_id >/dev/null 2>&1; then
  echo -e "${RED}Error: VM ID $template_id already exists in Proxmox!${RESET}"
  exit 1
fi

echo -e "${BLUE}Creating cloud-init template: $template_name with VM ID: $template_id${RESET}"

qm create $template_id --memory 2048 --core 2 --name $template_name --net0 virtio,bridge=vmbr0

qm importdisk $template_id $iso_file_name $proxmox_storage_name
qm set $template_id --scsi0 $proxmox_storage_name:vm-$template_id-disk-0
qm set $template_id --boot c --bootdisk scsi0
qm set $template_id --ide2 $proxmox_storage_name:cloudinit

qm template $template_id

echo -e "${GREEN}Cloud-init template creation completed successfully.${RESET}"
echo -e "${BLUE}Remember to update your Terraform variables to match the new template.${RESET}"
EOF