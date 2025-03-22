#!/bin/bash
# Define error handling function
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Update and install packages
echo "Updating system packages..."
apt update || handle_error "Failed to update packages"
apt upgrade -y || handle_error "Failed to upgrade packages"
echo "Installing required packages..."
apt install sudo nano tmux htop ffmpeg libsm6 libxext6 libcairo2-dev libjpeg-dev libgif-dev -y || handle_error "Failed to install packages"

# Download VS Code only if file doesn't exist
if [ ! -f "code.deb" ]; then
    echo "Downloading VS Code..."
    wget -O code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" || handle_error "Failed to download VS Code"
fi

echo "Installing VS Code..."
sudo apt install ./code.deb -y || handle_error "Failed to install VS Code"

# Check if SSH key already exists
if [ -f "/root/.ssh/id_rsa" ]; then
    read -p "SSH key already exists. Do you want to overwrite it? (y/n): " overwrite_key
    if [[ "$overwrite_key" == "y" || "$overwrite_key" == "Y" ]]; then
        echo "Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -C "jangyejun@gmail.com" -f /root/.ssh/id_rsa || handle_error "Failed to generate SSH key"
    else
        echo "Using existing SSH key."
    fi
else
    echo "Generating SSH key..."
    # Ensure .ssh directory exists
    mkdir -p /root/.ssh || handle_error "Failed to create .ssh directory"
    ssh-keygen -t rsa -b 4096 -C "jangyejun@gmail.com" -f /root/.ssh/id_rsa || handle_error "Failed to generate SSH key"
fi

echo "Here is your public SSH key:"
cat /root/.ssh/id_rsa.pub || handle_error "Failed to read public key"
read -p "Add this key to your GitHub account. Press enter to continue:"

echo "Setting Git configuration..."
git config --global user.name "Yejun Jang" || handle_error "Failed to set Git username"
git config --global user.email "jangyejun@gmail.com" || handle_error "Failed to set Git email"
git config pull.rebase false
echo "Git has been configured!"

echo "Adding GitHub to known hosts..."
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts || handle_error "Failed to add GitHub to known hosts"

echo "Changing to root directory..."
cd /root/ || handle_error "Failed to change to root directory"

# Validate repository name
read -p "Enter the repository name: " repo_name
if [ -z "$repo_name" ]; then
    handle_error "Repository name cannot be empty"
fi

# If folder exists
if [ -d "$repo_name" ]; then
    read -p "The folder /root/$repo_name/ already exists. Overwrite? (y/n) " overwrite
    if [ "$overwrite" = "y" ] || [ "$overwrite" = "Y" ]; then
        echo "removing folder $repo_name before cloning"
        rm -rf "$repo_name/" || handle_error "Failed to remove folder"
        echo "Cloning repository $repo_name..."
        git clone -b dev git@github.com:codingJang/$repo_name.git || handle_error "Failed to clone repository"
    fi
else
    git clone -b dev git@github.com:codingJang/$repo_name.git || handle_error "Failed to clone repository"
fi
echo "Successfully cloned repository $repo_name!"


echo "Changing to repository directory..."
cd /root/$repo_name || handle_error "Failed to change to repository directory"

echo "Fixing any broken pip installations..."
pip install --fix-broken-install

if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install --no-input -r requirements.txt || handle_error "Failed to install Python dependencies"
fi

# Ask directly for HF_TOKEN (can be skipped by pressing enter)
read -p "Enter your Hugging Face token (leave empty to skip): " hf_token
if [ -n "$hf_token" ]; then
    echo "Setting Hugging Face token..."
    export HF_TOKEN=$hf_token || handle_error "Failed to export HF_TOKEN"
    
    # Use tee instead of direct redirection for better error handling
    echo "export HF_TOKEN=$hf_token" | tee -a ~/.bashrc > /dev/null || handle_error "Failed to add HF_TOKEN to bashrc"
    echo "HF_TOKEN has been set and added to ~/.bashrc"
fi

# Source ~/.bashrc to apply changes
echo "Sourcing ~/.bashrc..."
source ~/.bashrc || handle_error "Failed to source ~/.bashrc"

# Get tunnel name and start VS Code tunnel
read -p "Enter VS Code tunnel name (leave empty to skip): " tunnel_name
if [ -n "$tunnel_name" ]; then
    echo "Starting VS Code tunnel with name: $tunnel_name inside a tmux session..."
    tmux new-session -A -s code_tunnel \; send -t code_tunnel "nohup code tunnel --name \"$tunnel_name\" &" ENTER \; detach -s code_tunnel || handle_error "Failed to start VS Code tunnel"
fi

echo "Setup completed successfully!"
