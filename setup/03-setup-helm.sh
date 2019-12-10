#!/bin/bash -x

# Reference: https://github.com/NVIDIA/gpu-operator/blob/0cc830a4c600411650c66b528fbd2d56da2f63a4/README.md

HELM_VERSION="v2.15.2"

# Download and install Helm
TMPDIR="$(mktemp -d)"
curl -L https://git.io/get_helm.sh -o "${TMPDIR}/get_helm.sh"
bash "${TMPDIR}/get_helm.sh" --version "${HELM_VERSION}"

# Create service-account for helm
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

# Initialize Helm
helm init --service-account tiller --upgrade --wait

# Note that if you have helm already deployed in your cluster and you are adding a new node, run this instead
#helm init --client-only

# Additional step required for Kubernetes v1.16. See: https://github.com/helm/helm/issues/6374
helm init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
kubectl wait --for=condition=available -n kube-system deployment tiller-deploy
