#!/bin/bash
# SSH Key Establisher to Proxmox Host
# This script establishes an SSH connection to the Proxmox host

GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

proxmox_host_name="${PROXMOX_HOST_NAME:-pve-1}"
proxmox_host_ip="${PROXMOX_HOST:-192.168.10.10}"
proxmox_host_username="${PROXMOX_USERNAME:-root}"

key_file="$HOME/.ssh/id_ed25519_${proxmox_host_name}"


echo -e "${BLUE}Setting up SSH key authentication for Proxmox host...${RESET}"

if [ -f "$key_file" ]; then
    echo -e "${YELLOW}SSH key already exists at $key_file${RESET}"
    echo -e "${BLUE}Proceeding with existing key...${RESET}"
else
    echo -e "${BLUE}Generating new SSH key...${RESET}"
    ssh-keygen -t ed25519 -f "$key_file" -C "Proxmox $proxmox_host_name Key" -N ""
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SSH key generated successfully${RESET}"
    else
        echo -e "${RED}Failed to generate SSH key${RESET}"
        exit 1
    fi
fi

echo -e "${BLUE}Copying SSH key to Proxmox host...${RESET}"
echo -e "${YELLOW}You may be prompted for the Proxmox root password...${RESET}"

ssh_copy_output=$(ssh-copy-id -i "$key_file.pub" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$proxmox_host_username@$proxmox_host_ip" 2>&1)
ssh_copy_exit_code=$?

if echo "$ssh_copy_output" | grep -q "All keys were skipped because they already exist"; then
    echo -e "${YELLOW}SSH key is already installed on the remote system.${RESET}"
    echo -e "${GREEN}SSH setup is already complete!${RESET}"
    exit 0
fi

if [ $ssh_copy_exit_code -eq 0 ]; then
    echo -e "${GREEN}SSH key copied successfully!${RESET}"
    echo -e "${BLUE}Ensuring PubkeyAuthentication is enabled on server...${RESET}"
    
    # Enable PubkeyAuthentication on the server
    ssh -i "$key_file" -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$proxmox_host_username@$proxmox_host_ip" "
        if grep -q '^#PubkeyAuthentication' /etc/ssh/sshd_config; then
            sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            sudo systemctl restart ssh
            echo 'PubkeyAuthentication enabled and SSH service restarted'
        elif ! grep -q '^PubkeyAuthentication yes' /etc/ssh/sshd_config; then
            echo 'PubkeyAuthentication yes' | sudo tee -a /etc/ssh/sshd_config
            sudo systemctl restart ssh
            echo 'PubkeyAuthentication enabled and SSH service restarted'
        else
            echo 'PubkeyAuthentication already properly configured'
        fi
    "
    echo -e "${BLUE}Testing SSH connection...${RESET}"
    
    ssh -i "$key_file" -q -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$proxmox_host_username@$proxmox_host_ip" "exit 0" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SSH connection test passed!${RESET}"
        
        echo -e "${BLUE}Adding SSH config entry...${RESET}"
        ssh_config_file="$HOME/.ssh/config"
        
        if [ ! -f "$ssh_config_file" ]; then
            touch "$ssh_config_file"
            chmod 600 "$ssh_config_file"
        fi
        
        if grep -q "Host $proxmox_host_name" "$ssh_config_file"; then
            echo -e "${YELLOW}SSH config entry for $proxmox_host_name already exists${RESET}"
        else
            cat >> "$ssh_config_file" << EOF
Host $proxmox_host_name
    HostName $proxmox_host_ip
    User $proxmox_host_username
    IdentityFile $key_file
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
            echo -e "${GREEN}SSH config entry added successfully!${RESET}"
            echo -e "${GREEN}You can now connect using: ssh $proxmox_host_name${RESET}"
        fi
    else
        echo -e "${RED}Failed to connect to Proxmox host${RESET}"
        echo -e "${RED}Please check:${RESET}"
        echo -e "${RED}1. Proxmox host is reachable at $proxmox_host_ip${RESET}"
        echo -e "${RED}2. SSH service is running on Proxmox${RESET}"
        exit 1
    fi
else
    echo -e "${RED}Failed to copy SSH key to Proxmox host${RESET}"
    echo -e "${RED}Please check:${RESET}"
    echo -e "${RED}1. Proxmox host is reachable at $proxmox_host_ip${RESET}"
    echo -e "${RED}2. SSH service is running on Proxmox${RESET}"
    exit 1
fi