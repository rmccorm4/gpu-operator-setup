#!/bin/bash -x

# Enforce running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] This script must be run with sudo." >&2
    exit 1
fi

# Clean up old Helm install artifacts
helm reset --force
kubectl delete all --selector app=helm -n kube-system
kubectl delete serviceaccount tiller -n kube-system
kubectl delete clusterrolebinding tiller-cluster-rule

if [[ $(command -v helm) ]]; then
    rm $(command -v helm)
fi

rm -rf ${HELM_HOME} ${HOME}/.helm
