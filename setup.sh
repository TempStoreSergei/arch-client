#!/bin/bash

# Source the functions script
source scripts/messages.sh
source scripts/utils.sh
source scripts/os.sh
source scripts/user.sh
source scripts/vpn.sh
source scripts/env.sh

# Path to JSON files
packages_file="json/packages.json"
services_file="json/services.json"

# Update system
update_system

# Read and install packages
read_packages "$packages_file"

# Create user if it doesn't exist and add to the seat group
setup_user

# Setup autologin
setup_autologin

# Setup OpenVPN client
setup_openvpn_client

# Read services
read_services "$services_file"

# Enable and start services
for service in "${services[@]}"; do
    enable_service "$service"
done
