#!/bin/bash
apt update
apt upgrade -y
apt install sudo nano tmux htop ffmpeg libsm6 libxext6 libcairo2-dev libjpeg-dev libgif-dev -y
wget -O code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo apt install ./code.deb -y
ssh-keygen -t rsa -b 4096 -C "jangyejun@gmail.com" -N "" -f /root/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub
read -p "Add this key to your GitHub account. Press enter to continue:"
git config --global user.name "Yejun Jang"
git config --global user.email "jangyejun@gmail.com"
echo "Git credentials have been set!"
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
cd /root/
rm -rf llm-fuzz/
read -p "Enter the repository name: " repo_name
git clone -b dev git@github.com:codingJang/$repo_name.git
echo "Repository $repo_name cloned successfully!"
cd /root/$repo_name || { echo "Failed to change directory. Exiting."; exit 1; }
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install --no-input -r requirements.txt
else
    echo "No requirements.txt found. Skipping dependency installation."
fi
echo "Setup complete!"

code tunnel --name snu-eng-dgx-light

