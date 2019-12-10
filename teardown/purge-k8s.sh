#!/bin/bash -x

# Enforce running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] This script must be run with sudo." >&2
    exit 1
fi

# Clean up old Kubernetes stuff
#kubectl drain ${HOSTNAME}
kubeadm reset --force
kubectl delete all
rm -rf ~/.kube/
rm -rf /etc/kubernetes
apt-get -y purge --allow-change-held-packages kubelet kubeadm kubectl
apt-get -y autoremove

echo "Wiping iptables..."
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
