#!/bin/bash -x

# Reference: https://docs.nvidia.com/datacenter/kubernetes/kubernetes-upstream/index.html#kubernetes-install-master-nodes

K8S_VERSION="1.15.6-00"
IGNORE_PREFLIGHT_ERRORS=${1:-"true"}

# Enforce running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] This script must be run with sudo." >&2
    exit 1
fi

# Install k8s pre-requisits
apt-get update && apt-get install -y apt-transport-https

# Add k8s deb repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
# No deb package for Ubuntu 18.04 currently
#deb https://apt.kubernetes.io/ $(lsb_release -c) main
# Use Ubuntu 16.04 package instead
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Install k8s components
apt-get update
apt-get install -y --allow-change-held-packages kubelet="${K8S_VERSION}" kubeadm="${K8S_VERSION}" kubectl="${K8S_VERSION}"
apt-mark hold kubelet kubeadm kubectl

# Setup k8s config
if [[ "${IGNORE_PREFLIGHT_ERRORS}" -eq "true" ]]; then
    kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors all
else
    kubeadm init --pod-network-cidr=10.244.0.0/16
fi

# Setup user
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown -R $(id $SUDO_USER -u):$(id $SUDO_USER -g) $HOME/.kube/

### From here on, run commands as the user ###

# Allow scheduling on master node
sudo -u $SUDO_USER kubectl taint nodes --all node-role.kubernetes.io/master-

### Setup Kubernetes Networking ###
sysctl net.bridge.bridge-nf-call-iptables=1

# This solved my issues with getting coredns pods to start successfully
# NOTE: This may not be desirable to run for all users. Perhaps there's another way.
echo "Wiping iptables..."
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

# Flannel Network Plugin
#sudo -u $SUDO_USER kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
# From current docs: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
sudo -u $SUDO_USER kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

SLEEP_TIME=60
echo "Sleeping for ${SLEEP_TIME} seconds to see if coredns starts successfully..."
sleep ${SLEEP_TIME}

# Try workaround for self-referencing nameserver in /etc/resolv.conf by pointing
# to the upstream nameservers in other resolv.conf file if coredns pods fail to start
COREDNS_FAILED=$(kubectl get pods --namespace kube-system | grep -i coredns | grep -i -e crashloopbackoff -e error)
if [[ ! -z ${COREDNS_FAILED} ]]; then
    echo "[ERROR] coredns failed to initialize."
    echo "Try running the following script to clean up various things, and then run this script again:"
    echo "    sudo ./misc/purge-k8s.sh"
    echo "    sudo ./02-setup-k8s.sh"
    echo 
    echo "If that still doesn't work, you can try consulting this page for troubleshooting:"
    echo "    https://github.com/coredns/coredns/tree/master/plugin/loop#troubleshooting-loops-in-kubernetes-clusters"
    #kubelet --resolv-conf /run/systemd/resolve/resolv.conf
fi

# NVIDIA Device Plugin - Don't install this when using GPU Operator
#sudo -u $SUDO_USER kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml

# Smoke test
sudo -u $SUDO_USER kubectl get all -n kube-system

