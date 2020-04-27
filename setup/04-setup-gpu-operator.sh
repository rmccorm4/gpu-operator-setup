#!/bin/bash -x

# Reference: https://github.com/NVIDIA/gpu-operator/tree/0cc830a4c600411650c66b528fbd2d56da2f63a4#install-gpu-operator

# Setup necessary modules
sudo modprobe -a i2c_core ipmi_msghandler
# Have modules load on reboot
echo -e "i2c_core\nipmi_msghandler" | sudo tee /etc/modules-load.d/driver.conf

# Add the NVIDIA repo:
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update

# Note that after running this command, NFD will be automatically deployed. If you have NFD already setup, follow the NFD instruction from the Prerequisites.
helm install --devel nvidia/gpu-operator --wait --generate-name

# To check the gpu-operator version
helm ls

# Check the status of the pods to ensure all the containers are running. A sample output is shown below in the cluster
kubectl get pods -A
