#!/bin/bash

set -x
DIRNAME=`dirname "$(realpath $0)"`
. "$DIRNAME/setup-lib.sh"

BACKEND_DEPLOY=$K8S_PKI/backend-deployment.yaml
BACKEND_SVC=$K8S_PKI/backend-service.yaml
FRONTEND_DEPLOY=$K8S_PKI/frontend-deployment.yaml
FRONTEND_SVC=$K8S_PKI/frontend-service.yaml

BACKEND_PLUGIN=$ENVOY_PLUGIN/backend
FRONTEND_PLUGIN=$ENVOY_PLUGIN/frontend

# Remove nginx TLS from backend deployment (HTTPS -> HTTP)
yq 'del(.spec.template.spec.volumes) | del(.spec.template.spec.containers[0].volumeMounts)' "$BACKEND_DEPLOY" --inplace
yq '.spec.template.spec.containers[0].ports[0].containerPort |= 80'  "$BACKEND_DEPLOY" --inplace

yq -i 'del(.services.backend.volumes)' "$DOCKER_PKI/docker-compose.yaml"
yq -i 'del(.services.backend.ports)' "$DOCKER_PKI/docker-compose.yaml"

sed -i.old '/nginx.conf$/d' "$DOCKER_PKI/backend/Dockerfile"
sed -i.old '/hosts$/d' "$DOCKER_PKI/backend/Dockerfile"

# Add Envoy plugin to backend deployemnt
yq eval-all '. as $item ireduce ({}; . *+ $item)' "$BACKEND_DEPLOY" "$BACKEND_PLUGIN/envoy-backend-deployment.yaml" --inplace

# Add Envoy plugin to backend service
export ENVOY_UPSTREAM_PORT=$(yq '.frontend.ENVOY_UPSTREAM_PORT' "$ENVOY_PLUGIN/metadata.yaml")
yq '.spec.ports[0].port |= env(ENVOY_UPSTREAM_PORT)' "$BACKEND_PLUGIN/envoy-backend-service.yaml" --inplace
yq '.spec.ports[0].targetPort |= env(ENVOY_UPSTREAM_PORT)' "$BACKEND_PLUGIN/envoy-backend-service.yaml" --inplace
yq '. *= load("/home/spire/spiresplash/envoy/plugin/backend/envoy-backend-service.yaml")' "$BACKEND_SVC" --inplace

# Add Envoy plugin to frontend deployment
yq eval-all '. as $item ireduce ({}; . *+ $item)' "$FRONTEND_DEPLOY" "$FRONTEND_PLUGIN/envoy-frontend-deployment.yaml" --inplace

# Add Envoy plugin to frontend service
export DOWNSTREAM_PORT=$(yq '.frontend.DOWNSTREAM_PORT' "$ENVOY_PLUGIN/metadata.yaml")
yq '.spec.ports[0].port |= env(DOWNSTREAM_PORT)' "$FRONTEND_PLUGIN/envoy-frontend-service.yaml" --inplace
yq '.spec.ports[0].targetPort |= env(DOWNSTREAM_PORT)' "$FRONTEND_PLUGIN/envoy-frontend-service.yaml" --inplace
yq '. *= load("/home/spire/spiresplash/envoy/plugin/frontend/envoy-frontend-service.yaml")' "$FRONTEND_SVC" --inplace

# Update frontend symbank-webapp.conf
ENVOY_DOWNSTREAM_PORT=$(yq '.frontend.ENVOY_DOWNSTREAM_PORT' "$ENVOY_PLUGIN/metadata.yaml")
DOWNSTREAM_PORT=$(yq '.frontend.DOWNSTREAM_PORT' "$ENVOY_PLUGIN/metadata.yaml")
UPSTREAM_PORT=$(yq '.frontend.UPSTREAM_PORT' "$ENVOY_PLUGIN/metadata.yaml")
sed -i 's/DOWNSTREAM_PORT/'"$DOWNSTREAM_PORT"'/' "$FRONTEND_PLUGIN/config/symbank-webapp.conf"
sed -i 's/UPSTREAM_PORT/'"$UPSTREAM_PORT"'/' "$FRONTEND_PLUGIN/config/symbank-webapp.conf"
sed -i 's/ENVOY_DOWNSTREAM_PORT/'"$ENVOY_DOWNSTREAM_PORT"'/' "$FRONTEND_PLUGIN/config/envoy.yaml"
sed -i 's/UPSTREAM_PORT/'"$UPSTREAM_PORT"'/' "$FRONTEND_PLUGIN/config/envoy.yaml"

# Prepare frontend docker context
cp "$FRONTEND_PLUGIN/config/symbank-webapp.conf" "$DOCKER_PKI/frontend/config/symbank-webapp.conf"
sed -i.old '/ca/d' "$DOCKER_PKI/frontend/Dockerfile"
