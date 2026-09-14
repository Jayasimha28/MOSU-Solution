#!/usr/bin/env bash
# Recreates the cka-lab kind cluster from kind-config.yaml.
# kind clusters don't reliably survive host reboots/Docker restarts,
# so if the control-plane container is dead, delete and recreate rather
# than trying to nurse it back.
set -euo pipefail

CLUSTER_NAME="cka-lab"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/kind-config.yaml"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "Deleting existing cluster: ${CLUSTER_NAME}"
  kind delete cluster --name "${CLUSTER_NAME}"
fi

echo "Creating cluster: ${CLUSTER_NAME}"
kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG_FILE}"

kubectl config use-context "kind-${CLUSTER_NAME}"
kubectl get nodes
