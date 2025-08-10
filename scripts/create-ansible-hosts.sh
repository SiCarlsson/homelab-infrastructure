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

VM_NAME_PREFIX="${LOCAL_VM_NAME_PREFIX:-local-vm}"
VM_USER="${TF_VAR_VM_USER:-ubuntu}"
DOCKER_VERSION="${DOCKER_VERSION:-5:28.3.3-1~ubuntu.24.04~noble}"
TIMEZONE="${TIMEZONE:-Europe/Stockholm}"

IP_WITH_SUBNET="$LOCAL_STARTING_IP_ADDRESS"
IP_ADDRESS="${IP_WITH_SUBNET%/*}"
SUBNET="${IP_WITH_SUBNET#*/}"


IFS='.' read -r -a IP_OCTETS <<< "$IP_ADDRESS"
BASE_IP="${IP_OCTETS[0]}.${IP_OCTETS[1]}.${IP_OCTETS[2]}"
STARTING_LAST_OCTET="${IP_OCTETS[3]}"

echo -e "${GREEN}Generating Ansible hosts inventory with loaded environment variables.${RESET}"

mkdir -p "$INVENTORY_DIR"

cat > "$HOSTS_FILE" << 'EOF'
# Ansible Inventory for Homelab VMs
# Generated automatically by create-ansible-hosts.sh

all:
  children:
    docker_hosts:
      hosts:
EOF

for ((i=1; i<=LOCAL_NUMBER_OF_VMS; i++)); do
    VM_NAME="$VM_NAME_PREFIX-$(printf "%02d" $i)"
    LAST_OCTET=$((STARTING_LAST_OCTET + i - 1))
    VM_IP_ADDRESS="$BASE_IP.$LAST_OCTET"

    echo "        $VM_NAME:" >> "$HOSTS_FILE"
    echo "          ansible_host: $VM_IP_ADDRESS" >> "$HOSTS_FILE"
done

cat >> "$HOSTS_FILE" << EOF
  vars:
    ansible_user: $VM_USER
    docker_version: "$DOCKER_VERSION"
    docker_users:
      - $VM_USER
    timezone: "$TIMEZONE"
EOF

echo -e "${GREEN}Successfully generated $HOSTS_FILE with $LOCAL_NUMBER_OF_VMS hosts${RESET}"
echo -e "${BLUE}Docker hosts group created with the following VMs:${RESET}"

for ((i=1; i<=LOCAL_NUMBER_OF_VMS; i++)); do
    VM_NAME="$VM_NAME_PREFIX-$(printf "%02d" $i)"
    LAST_OCTET=$((STARTING_LAST_OCTET + i - 1))
    VM_IP_ADDRESS="$BASE_IP.$LAST_OCTET"
    echo -e "${BLUE}  - $VM_NAME ($VM_IP_ADDRESS)${RESET}"
done