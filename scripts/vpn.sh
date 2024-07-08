
#!/bin/bash

get_server_ip() {
    read -p "Enter the OpenVPN server IP address: " SERVER_IP
    if ! ping -c 1 "$SERVER_IP" &>/dev/null; then
        error_msg "Server IP $SERVER_IP is not reachable."
        exit 1
    fi
    success_msg "Server IP $SERVER_IP is reachable."
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
}

# Function to create client configuration file using the curl command
create_client_config() {
    info_msg "Creating client configuration file..."
    RESPONSE=$(curl --header "Content-Type: application/json" --request POST --data "{\"name_client\":\"$CLIENT_NAME\"}" http://$SERVER_IP:2143/api/generate)
    if [[ $? -ne 0 ]]; then
        error_msg "Failed to generate client configuration."
        exit 1
    fi
    echo "$RESPONSE" > "/etc/openvpn/client/$CLIENT_NAME.conf"
    success_msg "Client configuration file created successfully."
}

# Function to download client files using curl
download_client_files() {
    info_msg "Downloading client files..."
    mkdir -p ~/home/openvpn/client/
    if ! curl -O "http://$SERVER_IP:2143/static/ca.crt" \
          -O "http://$SERVER_IP:2143/static/$CLIENT_NAME.conf" \
          -O "http://$SERVER_IP:2143/static/$CLIENT_NAME.key" \
          -O "http://$SERVER_IP:2143/static/$CLIENT_NAME.crt"; then
        error_msg "Failed to download client files."
        exit 1
    fi
    mv ca.crt "$CLIENT_NAME.conf" "$CLIENT_NAME.key" "$CLIENT_NAME.crt" ~/home/openvpn/client/
    success_msg "Client files downloaded successfully."
}

# Main function to setup OpenVPN client
setup_openvpn_client() {
    get_server_ip
    get_client_name
    generate_client_cert
    create_client_config
    download_client_files
}
