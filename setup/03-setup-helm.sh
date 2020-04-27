#!/bin/bash

# Download official Helm installer script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

# Install Helm
chmod 700 get_helm.sh
./get_helm.sh

# Cleanup
rm get_helm.sh
