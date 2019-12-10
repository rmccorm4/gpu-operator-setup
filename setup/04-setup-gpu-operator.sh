#!/bin/bash -x

# Reference: https://github.com/NVIDIA/gpu-operator/tree/0cc830a4c600411650c66b528fbd2d56da2f63a4#install-gpu-operator

# Setup necessary modules
sudo modprobe -a i2c_core ipmi_msghandler
# Have modules load on reboot
echo -e "i2c_core\nipmi_msghandler" | sudo tee /etc/modules-load.d/driver.conf

# Before running this, make sure helm is installed and initialized:
helm repo add nvidia https://nvidia.github.io/gpu-operator
helm repo update

# Note that after running this command, NFD will be automatically deployed. If you have NFD already setup, follow the NFD instruction from the Prerequisites.
helm install --devel nvidia/gpu-operator -n test-operator --wait
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/gpu-operator/master/manifests/cr/sro_cr_sched_none.yaml

SLEEP_TIME=60
echo "Sleeping for ${SLEEP_TIME} seconds to let pods start up..."
sleep ${SLEEP_TIME}

# Check GPU operator resources to see if pods are running
kubectl get pods --namespace gpu-operator-resources

# To check the gpu-operator version
helm ls
