#!/bin/bash -x

# Reference: https://docs.docker.com/install/linux/docker-ce/ubuntu/

# Enforce running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] This script must be run with sudo." >&2
    exit 1
fi

# Install prerequisite system packages
apt-get update && \
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

# Add docker deb repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install docker components
apt-get update && \
apt-get install docker-ce docker-ce-cli containerd.io

# Add user to group to avoid need for sudo after reboot
usermod -aG docker $USER
systemctl daemon-reload
systemctl restart docker
