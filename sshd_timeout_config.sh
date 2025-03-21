#!/bin/bash

# Desired SSH timeout settings
CLIENT_ALIVE_INTERVAL=120
CLIENT_ALIVE_COUNT_MAX=720

# SSH configuration file path
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

# Function to update or add a configuration parameter
update_config() {
    local param="$1"
    local value="$2"
    local file="$3"
    if grep -q "^${param}" "$file"; then
        sed -i "s/^${param}.*/${param} ${value}/" "$file"
    else
        echo "${param} ${value}" >> "$file"
}


# Update or add ClientAliveInterval
update_config "ClientAliveInterval" "$CLIENT_ALIVE_INTERVAL" "$SSHD_CONFIG_FILE"

# Update or add ClientAliveCountMax
update_config "ClientAliveCountMax" "$CLIENT_ALIVE_COUNT_MAX" "$SSHD_CONFIG_FILE"

# Start the SSH daemon manually
/usr/sbin/sshd -D &

echo "SSH timeout settings updated and sshd started successfully."