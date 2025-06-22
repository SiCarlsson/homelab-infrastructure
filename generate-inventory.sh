#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Generate the actual hosts file from the template
envsubst < ansible/inventory/hosts.ini.template > ansible/inventory/hosts

echo "Generated ansible/inventory/hosts from template"