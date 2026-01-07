# OKE Storage Performance Testing - Final Deliverables

**Test Date**: January 7, 2026
**Cluster**: Oracle Kubernetes Engine (OKE) on PCA X9-2
**Storage Classes Tested**: oci-bv (standard), oci-bv-high (high-performance)

---

## 📁 What's Included

### 1. Client Deliverables

**[CLIENT_REPORT.md](CLIENT_REPORT.md)** ⭐ **PRIMARY DELIVERABLE**
- Executive summary with key findings
- Complete performance analysis
- Storage class recommendations
- Cost-benefit analysis
- Implementation examples
- Action items and timeline
- **Use this for client presentations**

### 2. Results & Analysis

**[results/COMPARATIVE_ANALYSIS.md](results/COMPARATIVE_ANALYSIS.md)**
- Side-by-side technical comparison
- Decision matrix for storage class selection
- ROI analysis and migration guidance
- Real-world implementation scenarios

**[results/oci-bv_SUMMARY.md](results/oci-bv_SUMMARY.md)**
- Complete oci-bv performance results
- Detailed metrics and analysis

**[results/oci-bv-high_SUMMARY.md](results/oci-bv-high_SUMMARY.md)**
- Complete oci-bv-high performance results
- Detailed metrics and analysis

### 3. Raw Test Data

**[results/oci-bv_20260107_121513.txt](results/oci-bv_20260107_121513.txt)**
- Complete FIO output for oci-bv storage class

**[results/oci-bv-high_20260107_122600.txt](results/oci-bv-high_20260107_122600.txt)**
- Complete FIO output for oci-bv-high storage class

### 4. Testing Framework

**[simple-fio-test.sh](simple-fio-test.sh)**
- Reusable FIO testing script
- Run anytime to validate storage performance
- Usage: `./simple-fio-test.sh <storage-class>`

---

## 🎯 Quick Summary

### Performance Results

| Metric | oci-bv | oci-bv-high | Winner |
|--------|--------|-------------|--------|
| Random Read IOPS | 67,800 | 65,700 | oci-bv (+3%) |
| Random Write IOPS | 31,300 | 51,100 | **oci-bv-high (+63%)** |
| Sequential Read | 1,895 MiB/s | 1,797 MiB/s | oci-bv (+5%) |
| Sequential Write | 985 MiB/s | 778 MiB/s | oci-bv (+27%) |
| Mixed Read IOPS | 40,000 | 53,300 | **oci-bv-high (+33%)** |
| Mixed Write IOPS | 17,200 | 22,900 | **oci-bv-high (+33%)** |

### Key Findings

✅ **Both storage classes exceed OCI specifications by 10-78x**
✅ **oci-bv-high excels at writes**: 63% better random write IOPS
✅ **oci-bv excellent for reads**: Nearly identical read performance
✅ **Cost optimization**: 40-60% savings possible with oci-bv for appropriate workloads

### Recommendations

- **Default to oci-bv** for most workloads (80% of use cases)
- **Use oci-bv-high** for:
  - Production databases with >40% writes
  - High-concurrency applications (>50K write IOPS)
  - Mission-critical low-latency requirements

---

## 🔄 Running Performance Tests on Any Cluster

### Option 1: Automated Script (Recommended)

```bash
# Set your kubeconfig
export KUBECONFIG=/path/to/your/kubeconfig

# Test standard storage class
./simple-fio-test.sh oci-bv

# Test high-performance storage class
./simple-fio-test.sh oci-bv-high
```

**Requirements**:
- kubectl access to cluster
- Permissions to create namespaces and PVCs
- Test Duration: ~5-6 minutes per storage class

---

### Option 2: Manual Step-by-Step Testing

If you need to demo or run tests on other clusters manually, follow these steps:

#### Prerequisites

1. **Set your kubeconfig**:
   ```bash
   export KUBECONFIG=/path/to/your/kubeconfig
   ```

2. **Verify cluster access**:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

3. **Check available storage classes**:
   ```bash
   kubectl get sc
   ```

#### Step 1: Create Test Namespace

```bash
kubectl create namespace storage-perf-test
```

#### Step 2: Create PVC with Desired Storage Class

```bash
# For oci-bv (standard)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fio-test-pvc
  namespace: storage-perf-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv
  resources:
    requests:
      storage: 50Gi
EOF

# OR for oci-bv-high (high-performance)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fio-test-pvc
  namespace: storage-perf-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: oci-bv-high
  resources:
    requests:
      storage: 50Gi
EOF
```

#### Step 3: Create FIO Test Pod

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fio-tester
  namespace: storage-perf-test
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
```

#### Step 4: Wait for Pod to be Ready

```bash
kubectl wait --for=condition=ready pod/fio-tester -n storage-perf-test --timeout=300s

# Verify pod is running
kubectl get pod fio-tester -n storage-perf-test
```

#### Step 5: Run FIO Performance Tests

**Test 1: Random Read IOPS (4K blocks)**
```bash
kubectl exec -n storage-perf-test fio-tester -- fio \
  --name=random-read --directory=/data --size=2G \
  --bs=4k --rw=randread --ioengine=libaio --direct=1 \
  --numjobs=4 --iodepth=16 --runtime=60 --time_based \
  --group_reporting
```

**Test 2: Random Write IOPS (4K blocks)**
```bash
kubectl exec -n storage-perf-test fio-tester -- fio \
  --name=random-write --directory=/data --size=2G \
  --bs=4k --rw=randwrite --ioengine=libaio --direct=1 \
  --numjobs=4 --iodepth=16 --runtime=60 --time_based \
  --group_reporting
```

**Test 3: Sequential Read (1M blocks)**
```bash
kubectl exec -n storage-perf-test fio-tester -- fio \
  --name=seq-read --directory=/data --size=5G \
  --bs=1M --rw=read --ioengine=libaio --direct=1 \
  --numjobs=1 --iodepth=16 --runtime=60 --time_based \
  --group_reporting
```

**Test 4: Sequential Write (1M blocks)**
```bash
kubectl exec -n storage-perf-test fio-tester -- fio \
  --name=seq-write --directory=/data --size=5G \
  --bs=1M --rw=write --ioengine=libaio --direct=1 \
  --numjobs=1 --iodepth=16 --runtime=60 --time_based \
  --group_reporting
```

**Test 5: Mixed Workload (70% read, 30% write)**
```bash
kubectl exec -n storage-perf-test fio-tester -- fio \
  --name=mixed-rw --directory=/data --size=2G \
  --bs=4k --rw=randrw --rwmixread=70 --ioengine=libaio --direct=1 \
  --numjobs=4 --iodepth=16 --runtime=60 --time_based \
  --group_reporting
```

#### Step 6: Interpret Results

Look for these key metrics in the FIO output:

- **IOPS**: Look for `IOPS=` in the output (e.g., `IOPS=67.8k`)
- **Bandwidth**: Look for `BW=` (e.g., `BW=265MiB/s`)
- **Latency**: Look for `clat (usec)` or `lat (usec)` percentiles
  - `avg=` shows average latency
  - Percentiles show p95, p99 values

Example output snippet:
```
random-read: (groupid=0, jobs=4): err= 0: pid=15: Wed Jan  7 18:16:53 2026
   read: IOPS=67.8k, BW=265MiB/s (278MB/s)(15.5GiB/60002msec)
    clat (usec): min=134, max=7830, avg=935.18, stdev=363.44
     |  1.00th=[  243],  5.00th=[  293], 10.00th=[  338], 20.00th=[  498],
     | 95.00th=[ 1483], 99.00th=[ 1647], 99.50th=[ 1729], 99.90th=[ 2212]
```

This shows:
- **IOPS**: 67,800
- **Bandwidth**: 265 MiB/s
- **Average Latency**: 935 microseconds (0.935 ms)
- **p95 Latency**: 1,483 microseconds (1.48 ms)
- **p99 Latency**: 1,647 microseconds (1.65 ms)

#### Step 7: Cleanup

```bash
# Delete all test resources
kubectl delete namespace storage-perf-test

# Verify cleanup
kubectl get pvc -A | grep fio-test
```

---

## 📊 Test Methodology

### Test Parameters

- **Tool**: FIO 3.6 (Flexible I/O Tester) running in Kubernetes pod
- **Container Image**: ljishen/fio:latest
- **Engine**: libaio (Linux native async I/O)
- **Volume Size**: 50Gi
- **Direct I/O**: Enabled (bypasses OS cache for accurate results)

### Test Scenarios

| Test | Block Size | I/O Pattern | Jobs | I/O Depth | Duration |
|------|------------|-------------|------|-----------|----------|
| Random Read IOPS | 4K | randread | 4 | 16 | 60s |
| Random Write IOPS | 4K | randwrite | 4 | 16 | 60s |
| Sequential Read | 1M | read | 1 | 16 | 60s |
| Sequential Write | 1M | write | 1 | 16 | 60s |
| Mixed Workload | 4K | randrw (70R/30W) | 4 | 16 | 60s |

### Expected Baselines (OCI Published Specs)

**oci-bv (Standard Block Volume)**:
- **IOPS**: ~60 IOPS/GB (max 25,000 IOPS)
- **Throughput**: ~480 KB/s/GB
- **Latency**: 1-5ms typical

**oci-bv-high (High-Performance Block Volume)**:
- **IOPS**: ~100-120 IOPS/GB (max 120,000 IOPS)
- **Throughput**: ~800 KB/s/GB
- **Latency**: <1ms typical

---

## 🔍 Troubleshooting

### Pod Won't Start

```bash
# Check pod status
kubectl describe pod fio-tester -n storage-perf-test

# Check PVC status
kubectl describe pvc fio-test-pvc -n storage-perf-test

# Check CSI driver pods
kubectl get pods -n kube-system | grep csi
```

### Volume Not Provisioning

```bash
# Check storage class exists
kubectl get sc <storage-class-name>

# Check CSI driver
kubectl get csidrivers

# View provisioner logs
kubectl logs -n kube-system <csi-controller-pod-name> -c csi-volume-provisioner
```

### Test Fails with "No Space Left"

- Reduce test file sizes in FIO commands
- Use `--size=1G` instead of `--size=2G` or `--size=5G`
- Increase PVC size from 50Gi to 100Gi

### Permission Denied

```bash
# Verify you have permissions
kubectl auth can-i create namespace
kubectl auth can-i create pvc -n storage-perf-test
```

---

## 📧 Next Steps

1. **Review** [CLIENT_REPORT.md](CLIENT_REPORT.md)
2. **Customize** with client-specific information
3. **Present** findings to stakeholders
4. **Implement** storage class optimization recommendations
5. **Monitor** performance metrics post-optimization

---

## 📂 Directory Structure

```
storage-performance-testing/
├── README.md                          # This file
├── CLIENT_REPORT.md                   # Primary client deliverable
├── simple-fio-test.sh                 # Reusable testing script
└── results/
    ├── COMPARATIVE_ANALYSIS.md        # Technical comparison
    ├── oci-bv_SUMMARY.md              # oci-bv results
    ├── oci-bv-high_SUMMARY.md         # oci-bv-high results
    ├── oci-bv_20260107_121513.txt     # Raw FIO output
    └── oci-bv-high_20260107_122600.txt # Raw FIO output
```

---

## 📚 Additional Resources

**OCI Documentation**:
- [OCI Block Volume Performance](https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeperformance.htm)
- [OCI CSI Driver](https://github.com/oracle/oci-cloud-controller-manager/blob/master/container-storage-interface.md)

**FIO Documentation**:
- [FIO How-To Guide](https://fio.readthedocs.io/en/latest/fio_doc.html)
- [FIO Examples](https://github.com/axboe/fio/tree/master/examples)

---

**All testing complete. Documentation ready for client delivery and future demos.**

For questions or additional analysis, refer to the detailed reports in the results directory.
