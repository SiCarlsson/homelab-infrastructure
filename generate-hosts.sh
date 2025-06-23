#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  echo "✅ .env file found, proceeding..."
  export $(grep -v '^#' .env | xargs)
else
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file before running this script."
    exit 1
fi

# Generate the actual hosts file from the template
envsubst < ansible/inventory/hosts.template > ansible/inventory/hosts

echo "✅ Generated ansible/inventory/hosts from template"