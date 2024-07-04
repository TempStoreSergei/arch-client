
#!/bin/bash


# Function to ensure proper permissions for SSH directories and files
ensure_permissions() {
    local ssh_dir="$HOME/.ssh"
    local authorized_keys="$ssh_dir/authorized_keys"

    if [ ! -d "$ssh_dir" ]; then
        if ! mkdir -p "$ssh_dir" &>/dev/null || ! chmod 700 "$ssh_dir" &>/dev/null; then
            error_msg "Failed to create or set permissions for $ssh_dir."
            exit 1
        fi
    fi

    if [ ! -f "$authorized_keys" ]; then
        if ! touch "$authorized_keys" &>/dev/null || ! chmod 600 "$authorized_keys" &>/dev/null; then
            error_msg "Failed to create or set permissions for $authorized_keys."
            exit 1
        fi
    fi

    success_msg "Permissions set successfully for SSH directories and files."
}

# Function to generate SSH key pair
generate_ssh_keys() {
    local key_path="$HOME/.ssh/id_rsa"

    if [ ! -f "$key_path" ]; then
        info_msg "Generating SSH key pair..."
        if ! ssh-keygen -t rsa -b 4096 -f "$key_path" -N "" &>/dev/null; then
            error_msg "Failed to generate SSH key pair."
            exit 1
        fi
        success_msg "SSH key pair generated successfully."
    else
        info_msg "SSH key pair already exists. Skipping generation."
    fi
}

# Function to add SSH public key to authorized_keys
add_key_to_authorized_keys() {
    local key_path="$HOME/.ssh/id_rsa.pub"
    local authorized_keys="$HOME/.ssh/authorized_keys"

    if ! grep -q "$(cat "$key_path")" "$authorized_keys"; then
        info_msg "Adding SSH public key to authorized_keys..."
        if ! cat "$key_path" >> "$authorized_keys"; then
            error_msg "Failed to add SSH public key to authorized_keys."
            exit 1
        fi
        success_msg "SSH public key added to authorized_keys."
    else
        info_msg "SSH public key already in authorized_keys. Skipping addition."
    fi
}

# Function to configure SSH client
configure_ssh_client() {
    local ssh_config="$HOME/.ssh/config"

    info_msg "Configuring SSH client..."
    {
        echo "Host myserver"
        echo "    HostName your.server.com"
        echo "    User your_username"
        echo "    IdentityFile ~/.ssh/id_rsa"
    } >> "$ssh_config"

    success_msg "SSH client configured successfully."
}

# Main function to setup SSH client
setup_ssh_client() {
    ensure_permissions
    generate_ssh_keys
    add_key_to_authorized_keys
    configure_ssh_client
}
