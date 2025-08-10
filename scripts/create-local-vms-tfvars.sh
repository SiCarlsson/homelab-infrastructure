#!/bin/bash

# Local VMs Terraform Variables Generator
# Script to generate local-vms.auto.tfvars based on environment variables
# Expected to be run from Makefile with .env variables already loaded

GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
RESET='\033[0m'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
TFVARS_FILE="$TERRAFORM_DIR/local-vms.auto.tfvars"

if [[ -z "${LOCAL_NUMBER_OF_VMS:-}" ]]; then
    echo -e "${RED}Error: LOCAL_NUMBER_OF_VMS environment variable is not set${RESET}"
    echo -e "${RED}Make sure this script is run from the Makefile with .env variables loaded${RESET}"
    exit 1
fi

if [[ -z "${LOCAL_STARTING_IP_ADDRESS:-}" ]]; then
    echo -e "${RED}Error: LOCAL_STARTING_IP_ADDRESS environment variable is not set${RESET}"
    echo -e "${RED}Make sure this script is run from the Makefile with .env variables loaded${RESET}"
    exit 1
fi

if [[ -z "${LOCAL_STARTING_VM_ID:-}" ]]; then
    echo -e "${RED}Error: LOCAL_STARTING_VM_ID environment variable is not set${RESET}"
    echo -e "${RED}Make sure this script is run from the Makefile with .env variables loaded${RESET}"
    exit 1
fi

VM_NAME_PREFIX="${LOCAL_VM_NAME_PREFIX:-local-vm}"

VM_CORES="${LOCAL_VM_CORES:-2}"
VM_MEMORY="${LOCAL_VM_MEMORY:-4096}"
VM_DISK_SIZE="${LOCAL_VM_DISK_SIZE:-32}"

IP_WITH_SUBNET="$LOCAL_STARTING_IP_ADDRESS"
IP_ADDRESS="${IP_WITH_SUBNET%/*}"
SUBNET="${IP_WITH_SUBNET#*/}"

IFS='.' read -r -a IP_OCTETS <<< "$IP_ADDRESS"
BASE_IP="${IP_OCTETS[0]}.${IP_OCTETS[1]}.${IP_OCTETS[2]}"
STARTING_LAST_OCTET="${IP_OCTETS[3]}"

echo -e "${GREEN}Generating tfvars with loaded environment variables.${RESET}"

cat > "$TFVARS_FILE" << 'EOF'
# Local VMs Configuration
# This file defines the local VMs to be created in your homelab
# Generated automatically by create-local-vms-tfvars.sh

LOCAL_VMS = {
EOF

for ((i=1; i<=LOCAL_NUMBER_OF_VMS; i++)); do
    VM_KEY="$VM_NAME_PREFIX-$i"
    VM_NAME="$VM_NAME_PREFIX-$(printf "%02d" $i)"
    VM_ID=$((LOCAL_STARTING_VM_ID + i - 1))
    LAST_OCTET=$((STARTING_LAST_OCTET + i - 1))
    VM_IP_ADDRESS="$BASE_IP.$LAST_OCTET/$SUBNET"

    echo "  \"$VM_KEY\" = {" >> "$TFVARS_FILE"
    echo "    name       = \"$VM_NAME\"" >> "$TFVARS_FILE"
    echo "    vm_id      = $VM_ID" >> "$TFVARS_FILE"
    echo "    ip_address = \"$VM_IP_ADDRESS\"" >> "$TFVARS_FILE"
    echo "    cores      = $VM_CORES" >> "$TFVARS_FILE"
    echo "    memory     = $VM_MEMORY" >> "$TFVARS_FILE"
    echo "    disk_size  = $VM_DISK_SIZE" >> "$TFVARS_FILE"
    echo "  }" >> "$TFVARS_FILE"
done

echo "}" >> "$TFVARS_FILE"
echo "" >> "$TFVARS_FILE"

echo -e "${GREEN}Successfully generated $TFVARS_FILE with $LOCAL_NUMBER_OF_VMS VMs${RESET}"
for ((i=1; i<=LOCAL_NUMBER_OF_VMS; i++)); do
    VM_NAME="$VM_NAME_PREFIX-$(printf "%02d" $i)"
    VM_ID=$((LOCAL_STARTING_VM_ID + i - 1))
    LAST_OCTET=$((STARTING_LAST_OCTET + i - 1))
    VM_IP_ADDRESS="$BASE_IP.$LAST_OCTET/$SUBNET"
    echo -e "${BLUE}  - $VM_NAME (ID: $VM_ID, IP: $VM_IP_ADDRESS, Cores: $VM_CORES, Memory: ${VM_MEMORY}MB, Disk: ${VM_DISK_SIZE}GB)${RESET}"
done