
#!/bin/bash

# Function to prompt for and validate the server IP address
get_server_ip() {
    read -p "Enter the OpenVPN server IP address: " SERVER_IP
    if ! ping -c 1 "$SERVER_IP" &>/dev/null; then
        error_msg "Server IP $SERVER_IP is not reachable."
        exit 1
    fi
    success_msg "Server IP $SERVER_IP is reachable."
}

# Function to check if the OpenVPN server is running
check_openvpn_server() {
    if ! nc -z "$SERVER_IP" 51000 &>/dev/null; then
        error_msg "OpenVPN server is not running on $SERVER_IP:51000."
        exit 1
    fi
    success_msg "OpenVPN server is running on $SERVER_IP:51000."
}

# Function to prompt for and validate the client name
get_client_name() {
    read -p "Enter the client name: " CLIENT_NAME
    if ssh -o BatchMode=yes "$SERVER_IP" "[ -d /etc/openvpn/server/$CLIENT_NAME ]"; then
        error_msg "Client name $CLIENT_NAME already exists on the server."
        exit 1
    fi
    success_msg "Client name $CLIENT_NAME is available."
}

# Function to generate client certificates and keys
generate_client_cert() {
    info_msg "Generating client certificate and key..."
    cd /etc/easy-rsa || { error_msg "Failed to change directory."; exit 1; }
    if ! sudo easyrsa --batch gen-req "$CLIENT_NAME" nopass &>/dev/null; then
        error_msg "Failed to generate client certificate and key."
        exit 1
    fi
    echo -e "yes\n" | sudo easyrsa --batch sign-req client "$CLIENT_NAME" &>/dev/null || { error_msg "Failed to sign client certificate."; exit 1; }
    success_msg "Client certificate and key generated successfully."
}

# Function to create client configuration file
create_client_config() {
    info_msg "Creating client configuration file..."
    CLIENT_CONFIG_PATH="/etc/openvpn/client/$CLIENT_NAME.conf"
    sudo bash -c "cat <<EOF > \"$CLIENT_CONFIG_PATH\"
    client
    dev tun
    proto udp
    remote $SERVER_IP 51000
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    ca ca.crt
    cert $CLIENT_NAME.crt
    key $CLIENT_NAME.key
    tls-auth ta.key 1
    cipher AES-256-GCM
    auth SHA256
    verb 3
    EOF"
    success_msg "Client configuration file created successfully."
}

# Function to copy client files to server using SCP
copy_client_files_to_server() {
    info_msg "Copying client files to server..."
    if ! sudo scp "/etc/openvpn/client/$CLIENT_NAME.conf" "$SERVER_IP:/etc/openvpn/client/"; then
        error_msg "Failed to copy client files to server."
        exit 1
    fi
    success_msg "Client files copied to server successfully."
}

# Main function to setup OpenVPN client
setup_openvpn_client() {
    get_server_ip
    get_client_name
    generate_client_cert
    create_client_config
    copy_client_files_to_server
}
