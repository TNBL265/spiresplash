#!/bin/bash

set -x
DIRNAME=$(dirname "$(realpath "$0")")
. "$DIRNAME/setup-lib.sh"

# Create directory to store k8s yaml
rm -rf "$K8S_PKI"
mkdir -p "$K8S_PKI"

#  Convert docker-compose.yaml into k8s configuration files
kompose convert -f "$DOCKER_PKI/docker-compose.yaml" -o "$K8S_PKI" --volumes emptyDir && sleep 1

# Update backend deployment to use kubernets secrete for TLS
export VOL_NAME=$(yq '.spec.template.spec.containers[0].volumeMounts[0].name' "$K8S_PKI/backend-deployment.yaml")
yq e '.spec.template.spec.volumes[0] = {"secret":{"secretName":"backend-tls"}, "name":""}' \
    "$K8S_PKI/backend-deployment.yaml" --inplace
yq e '.spec.template.spec.volumes[0].name = env(VOL_NAME)' \
    "$K8S_PKI/backend-deployment.yaml" --inplace

# Convert StepCA private key and certificate into TLS Secret
kubectl create secret tls backend-tls --key "$DOCKER_PKI/certs/backend/tls.key" --cert "$DOCKER_PKI/certs/backend/tls.crt"

# Deploy backend service first
kubectl apply -f "$K8S_PKI/backend-service.yaml" && sleep 1

# Get backend service IP address
BACKEND_SVC=$(kubectl get svc --field-selector metadata.name=backend -o jsonpath='{.items[0].spec.clusterIP}')
kubectl apply -f "$K8S_PKI"