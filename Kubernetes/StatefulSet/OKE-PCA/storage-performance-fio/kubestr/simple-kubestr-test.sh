#!/bin/bash

# Simple kubestr Storage Performance Testing Script
# Usage: ./simple-kubestr-test.sh <storage-class>
# Example: ./simple-kubestr-test.sh oci-bv

set -e

# Check if storage class argument is provided
if [ -z "$1" ]; then
    echo "Error: Storage class not specified"
    echo "Usage: $0 <storage-class>"
    echo "Example: $0 oci-bv"
    exit 1
fi

STORAGE_CLASS=$1
KUBECONFIG=${KUBECONFIG:-~/.kube/config}
NAMESPACE="kubestr-test"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/kubestr_${STORAGE_CLASS}_${TIMESTAMP}.json"

echo "=========================================="
echo "Kubestr Storage Performance Test"
echo "Storage Class: ${STORAGE_CLASS}"
echo "Timestamp: ${TIMESTAMP}"
echo "=========================================="
echo ""

# Create results directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

# Export kubeconfig
export KUBECONFIG=${KUBECONFIG}

echo ">>> Running kubestr FIO test..."
echo "This will create a 50Gi PVC and run performance tests"
echo ""

# Run kubestr with default FIO test
./kubestr fio \
    --storageclass ${STORAGE_CLASS} \
    --size 50Gi \
    --namespace ${NAMESPACE} \
    --output json \
    --outfile ${OUTPUT_FILE}

echo ""
echo "=========================================="
echo "Test completed!"
echo "Results saved to: ${OUTPUT_FILE}"
echo "=========================================="
echo ""
echo "To view results:"
echo "  cat ${OUTPUT_FILE} | jq ."
echo ""
echo "To cleanup:"
echo "  kubectl delete namespace ${NAMESPACE}"
