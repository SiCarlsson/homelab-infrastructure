#!/bin/bash

# VMs Terraform Variables Generator
# Script to generate local-vms.auto.tfvars and public-vms.auto.tfvars based on environment variables
# Expected to be run from Makefile with .env variables already loaded

GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

generate_vm_tfvars() {
    # Set variables
    local vm_type="$1"
    local number_of_vms_var="${vm_type}_NUMBER_OF_VMS"
    local starting_ip_var="${vm_type}_STARTING_IP_ADDRESS"
    local starting_vm_id_var="${vm_type}_STARTING_VM_ID"
    local vm_name_prefix_var="${vm_type}_VM_NAME_PREFIX"
    local vm_cores_var="${vm_type}_VM_CORES"
    local vm_memory_var="${vm_type}_VM_MEMORY"
    local vm_disk_size_var="${vm_type}_VM_DISK_SIZE"
    
    local number_of_vms="${!number_of_vms_var:-}"
    local starting_ip="${!starting_ip_var:-}"
    local starting_vm_id="${!starting_vm_id_var:-}"
    
    # Skip if required variables are not set
    if [[ -z "$number_of_vms" || -z "$starting_ip" || -z "$starting_vm_id" ]]; then
        echo -e "${BLUE}Skipping ${vm_type} VMs - not all required variables are set${RESET}"
        return 0
    fi
    
    # Set defaults for optional variables
    local vm_name_prefix="${!vm_name_prefix_var:-$(echo "$vm_type" | tr '[:upper:]' '[:lower:]')-vm}"
    local vm_cores="${!vm_cores_var:-2}"
    local vm_memory="${!vm_memory_var:-4096}"
    local vm_disk_size="${!vm_disk_size_var:-32}"
    
    local tfvars_file="$TERRAFORM_DIR/$(echo "$vm_type" | tr '[:upper:]' '[:lower:]')-vms.auto.tfvars"
    local vm_variable_name="${vm_type}_VMS"
    
    # Parse IP address
    local ip_with_subnet="$starting_ip"
    local ip_address="${ip_with_subnet%/*}"
    local subnet="${ip_with_subnet#*/}"
    
    IFS='.' read -r -a ip_octets <<< "$ip_address"
    local base_ip="${ip_octets[0]}.${ip_octets[1]}.${ip_octets[2]}"
    local starting_last_octet="${ip_octets[3]}"
    
    echo -e "${GREEN}Generating $tfvars_file with $number_of_vms VMs${RESET}"
    
    # Convert vm_type to proper case for comments
    local vm_type_upper=$(echo "$vm_type" | tr '[:lower:]' '[:upper:]')
    local vm_type_lower=$(echo "$vm_type" | tr '[:upper:]' '[:lower:]')
    
    cat > "$tfvars_file" << EOF
# ${vm_type_upper} VMs Configuration
# This file defines the ${vm_type_lower} VMs to be created in your homelab
# Generated automatically by create-vms-tfvars.sh

${vm_variable_name} = {
EOF

    for ((i=1; i<=number_of_vms; i++)); do
        local vm_key="$vm_name_prefix-$i"
        local vm_name="$vm_name_prefix-$(printf "%02d" $i)"
        local vm_id=$((starting_vm_id + i - 1))
        local last_octet=$((starting_last_octet + i - 1))
        local vm_ip_address="$base_ip.$last_octet/$subnet"

        echo "  \"$vm_key\" = {" >> "$tfvars_file"
        echo "    name       = \"$vm_name\"" >> "$tfvars_file"
        echo "    vm_id      = $vm_id" >> "$tfvars_file"
        echo "    ip_address = \"$vm_ip_address\"" >> "$tfvars_file"
        echo "    cores      = $vm_cores" >> "$tfvars_file"
        echo "    memory     = $vm_memory" >> "$tfvars_file"
        echo "    disk_size  = $vm_disk_size" >> "$tfvars_file"
        echo "  }" >> "$tfvars_file"
    done

    echo "}" >> "$tfvars_file"
    echo "" >> "$tfvars_file"

    echo -e "${GREEN}Successfully generated $tfvars_file with $number_of_vms VMs${RESET}"
    for ((i=1; i<=number_of_vms; i++)); do
        local vm_name="$vm_name_prefix-$(printf "%02d" $i)"
        local vm_id=$((starting_vm_id + i - 1))
        local last_octet=$((starting_last_octet + i - 1))
        local vm_ip_address="$base_ip.$last_octet/$subnet"
        echo -e "${BLUE}  - $vm_name (ID: $vm_id, IP: $vm_ip_address, Cores: $vm_cores, Memory: ${vm_memory}MB, Disk: ${vm_disk_size}GB)${RESET}"
    done
}

generate_vm_tfvars "LOCAL"
generate_vm_tfvars "PUBLIC"
