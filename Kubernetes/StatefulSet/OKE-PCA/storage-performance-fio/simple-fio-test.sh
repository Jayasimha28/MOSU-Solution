#!/bin/bash
#
# Simplified FIO Storage Performance Test
#

set -e

export KUBECONFIG=/tmp/config
STORAGE_CLASS="${1:-oci-bv}"
NAMESPACE="storage-perf-test"
POD_NAME="fio-tester"
RESULTS_DIR="./results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/${STORAGE_CLASS}_${TIMESTAMP}.txt"

mkdir -p "${RESULTS_DIR}"

echo "=========================================="
echo "OKE Storage Performance Test"
echo "Storage Class: ${STORAGE_CLASS}"
echo "=========================================="

# Create namespace
kubectl create namespace ${NAMESPACE} 2>/dev/null || true

# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fio-test-pvc
  namespace: ${NAMESPACE}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ${STORAGE_CLASS}
  resources:
    requests:
      storage: 50Gi
EOF

# Create pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
  namespace: ${NAMESPACE}
spec:
  containers:
  - name: fio
    image: ljishen/fio:latest
    command: ["/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: test-volume
      mountPath: /data
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "2000m"
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: fio-test-pvc
EOF

echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/${POD_NAME} -n ${NAMESPACE} --timeout=300s

echo "Pod is ready! Starting FIO tests..."
echo ""

# Run tests
exec > >(tee "${OUTPUT_FILE}") 2>&1

echo "=========================================="
echo "Test Results: ${STORAGE_CLASS}"
echo "Date: $(date)"
echo "=========================================="
echo ""

echo ">>> Test 1/5: Random Read IOPS (4K blocks, 60s)"
kubectl exec -n ${NAMESPACE} ${POD_NAME} -- fio \
    --name=random-read --directory=/data --size=2G \
    --bs=4k --rw=randread --ioengine=libaio --direct=1 \
    --numjobs=4 --iodepth=16 --runtime=60 --time_based \
    --group_reporting

echo ""
echo ">>> Test 2/5: Random Write IOPS (4K blocks, 60s)"
kubectl exec -n ${NAMESPACE} ${POD_NAME} -- fio \
    --name=random-write --directory=/data --size=2G \
    --bs=4k --rw=randwrite --ioengine=libaio --direct=1 \
    --numjobs=4 --iodepth=16 --runtime=60 --time_based \
    --group_reporting

echo ""
echo ">>> Test 3/5: Sequential Read (1M blocks, 60s)"
kubectl exec -n ${NAMESPACE} ${POD_NAME} -- fio \
    --name=seq-read --directory=/data --size=5G \
    --bs=1M --rw=read --ioengine=libaio --direct=1 \
    --numjobs=1 --iodepth=16 --runtime=60 --time_based \
    --group_reporting

echo ""
echo ">>> Test 4/5: Sequential Write (1M blocks, 60s)"
kubectl exec -n ${NAMESPACE} ${POD_NAME} -- fio \
    --name=seq-write --directory=/data --size=5G \
    --bs=1M --rw=write --ioengine=libaio --direct=1 \
    --numjobs=1 --iodepth=16 --runtime=60 --time_based \
    --group_reporting

echo ""
echo ">>> Test 5/5: Mixed Workload (70% read, 30% write, 60s)"
kubectl exec -n ${NAMESPACE} ${POD_NAME} -- fio \
    --name=mixed-rw --directory=/data --size=2G \
    --bs=4k --rw=randrw --rwmixread=70 --ioengine=libaio --direct=1 \
    --numjobs=4 --iodepth=16 --runtime=60 --time_based \
    --group_reporting

echo ""
echo "=========================================="
echo "Tests completed!"
echo "Results saved to: ${OUTPUT_FILE}"
echo "=========================================="
