#!/bin/bash

# Reference: https://github.com/NVIDIA/gpu-operator#running-a-sample-gpu-application

# Create a tensorflow notebook example
kubectl apply -f https://nvidia.github.io/gpu-operator/notebook-example.yml

SLEEP_TIME=180
echo "Sleeping for ${SLEEP_TIME} seconds to let pods start up..."
sleep ${SLEEP_TIME}

# Grab the token from the pod once it is created
kubectl get pod tf-notebook
kubectl logs tf-notebook
