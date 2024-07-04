#!/bin/bash

# Function to create user if it doesn't exist and add to the seat group
setup_user() {
    local username="fsuser"
    
    if id "$username" &>/dev/null; then
        info_msg "User '$username' already exists."
    else
        info_msg "Creating user '$username'..."
        if ! sudo useradd -m -G seat "$username" || ! echo "$username:admin" | sudo chpasswd; then
            error_msg "Failed to create user '$username'."
            exit 1
        fi
        success_msg "User '$username' created successfully."
    fi
}

# Function to setup autologin
setup_autologin() {
    local username="fsuser"
    
    info_msg "Setting up autologin for $username..."
    if ! sudo mkdir -p /etc/systemd/system/getty@tty1.service.d ||
       ! sudo cp conf/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf; then
        error_msg "Failed to setup autologin."
        exit 1
    fi
    success_msg "Autologin setup for $username successfully."
}