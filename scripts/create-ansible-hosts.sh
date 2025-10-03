#!/bin/bash

# Ansible Hosts Inventory Generator
# Script to generate hosts.yml based on environment variables
# Expected to be run from Makefile with .env variables already loaded

GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"
INVENTORY_DIR="$ANSIBLE_DIR/inventory"
HOSTS_FILE="$INVENTORY_DIR/hosts.yml"

generate_host_entries() {
    local vm_type="$1"
    local number_of_vms_var="${vm_type}_NUMBER_OF_VMS"
    local starting_ip_var="${vm_type}_STARTING_IP_ADDRESS"
    local vm_name_prefix_var="${vm_type}_VM_NAME_PREFIX"

    local number_of_vms="${!number_of_vms_var:-}"
    local starting_ip="${!starting_ip_var:-}"
    
    # Skip if required variables are not set
    if [[ -z "$number_of_vms" || -z "$starting_ip" ]]; then
        return 1
    fi

    local vm_name_prefix="${!vm_name_prefix_var:-$(echo "$vm_type" | tr '[:upper:]' '[:lower:]')-vm}"
    
    # Parse IP address
    local ip_with_subnet="$starting_ip"
    local ip_address="${ip_with_subnet%/*}"
    
    IFS='.' read -r -a ip_octets <<< "$ip_address"
    local base_ip="${ip_octets[0]}.${ip_octets[1]}.${ip_octets[2]}"
    local starting_last_octet="${ip_octets[3]}"
    
    local group_name="$(echo "$vm_type" | tr '[:upper:]' '[:lower:]')_docker_hosts"
    
    echo "    $group_name:" >> "$HOSTS_FILE"
    echo "      hosts:" >> "$HOSTS_FILE"
    
    for ((i=1; i<=number_of_vms; i++)); do
        local vm_name="$vm_name_prefix-$(printf "%02d" $i)"
        local last_octet=$((starting_last_octet + i - 1))
        local vm_ip_address="$base_ip.$last_octet"

        echo "        $vm_name:" >> "$HOSTS_FILE"
        echo "          ansible_host: $vm_ip_address" >> "$HOSTS_FILE"
    done
    
    return 0
}

VM_USER="${TF_VAR_VM_USER:-ubuntu}"
DOCKER_VERSION="${DOCKER_VERSION:-5:28.3.3-1~ubuntu.24.04~noble}"
TIMEZONE="${TIMEZONE:-Europe/Stockholm}"

echo -e "${GREEN}Generating Ansible hosts inventory with loaded environment variables.${RESET}"

mkdir -p "$INVENTORY_DIR"

cat > "$HOSTS_FILE" << 'EOF'
# Ansible Inventory for Homelab VMs
# Generated automatically by create-ansible-hosts.sh

all:
  children:
EOF

generate_host_entries "LOCAL"
generate_host_entries "PUBLIC"

cat >> "$HOSTS_FILE" << EOF
  vars:
    ansible_user: $VM_USER
    docker_version: "$DOCKER_VERSION"
    docker_users:
      - $VM_USER
    timezone: "$TIMEZONE"
EOF

echo -e "${GREEN}Successfully generated $HOSTS_FILE${RESET}"