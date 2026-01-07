# Kubestr Storage Performance Testing

## What is Kubestr?

Kubestr is a collection of tools to discover, validate and evaluate Kubernetes storage options. It helps identify optimal storage configurations and performance characteristics.

**GitHub**: https://github.com/kastenhq/kubestr

---

## Quick Start

### Option 1: Automated Script

```bash
# Set your kubeconfig
export KUBECONFIG=/path/to/your/kubeconfig

# Run test on storage class
./simple-kubestr-test.sh oci-bv

# Run test on high-performance storage class
./simple-kubestr-test.sh oci-bv-high
```

### Option 2: Manual kubestr Commands

```bash
# Basic FIO test
./kubestr fio --storageclass oci-bv --size 50Gi

# Save results to JSON file
./kubestr fio \
    --storageclass oci-bv \
    --size 50Gi \
    --output json \
    --outfile results/oci-bv-results.json

# Run with custom namespace
./kubestr fio \
    --storageclass oci-bv \
    --size 50Gi \
    --namespace storage-test
```

---

## Kubestr Commands

### 1. FIO Performance Testing

```bash
# Run default FIO test
./kubestr fio --storageclass <storage-class>

# Custom volume size
./kubestr fio --storageclass oci-bv --size 100Gi

# JSON output
./kubestr fio --storageclass oci-bv --output json
```

### 2. CSI Snapshot Check

```bash
# Test snapshot capabilities
./kubestr csicheck --storageclass oci-bv --volumesnapshotclass <snapshot-class>
```

### 3. Block Volume Support

```bash
# Check if storage class supports block volumes
./kubestr blockmount --storageclass oci-bv
```

### 4. Storage Class Discovery

```bash
# List and analyze all storage classes (run without flags)
./kubestr
```

---

## Understanding Kubestr FIO Test

### What Tests Does It Run?

Kubestr runs a **default FIO test profile** that includes:

1. **Random Read** (4K blocks)
2. **Random Write** (4K blocks)
3. **Sequential Read** (128K blocks)
4. **Sequential Write** (128K blocks)

### Test Parameters

Default configuration:
- **Block Size**: 4K (random), 128K (sequential)
- **I/O Depth**: 64
- **Jobs**: 4 parallel jobs
- **Runtime**: 60 seconds per test
- **Direct I/O**: Enabled
- **Volume Size**: 100Gi (default, configurable)

---

## Interpreting Results

### JSON Output Structure

```json
{
  "FIOReport": {
    "IOPs": {
      "Read": 12345,
      "Write": 6789
    },
    "Bandwidth": {
      "Read": "123.45 MiB/s",
      "Write": "67.89 MiB/s"
    },
    "Latency": {
      "Read": "1.23 ms",
      "Write": "2.34 ms"
    }
  }
}
```

### Key Metrics to Look For

| Metric | Description | Good Performance |
|--------|-------------|------------------|
| **Random Read IOPS** | 4K random read operations/sec | >50,000 |
| **Random Write IOPS** | 4K random write operations/sec | >30,000 |
| **Sequential Read** | Large file read throughput | >1,000 MiB/s |
| **Sequential Write** | Large file write throughput | >500 MiB/s |
| **Read Latency** | Average time for read operation | <2ms |
| **Write Latency** | Average time for write operation | <5ms |

---

## Kubestr vs FIO Comparison

| Feature | Kubestr | FIO (Manual) |
|---------|---------|--------------|
| **Installation** | Single binary | Container-based |
| **Ease of Use** | Very easy - one command | Requires kubectl exec |
| **Test Customization** | Limited - predefined tests | Full control over parameters |
| **Output Format** | JSON, text | Raw FIO output |
| **Snapshot Testing** | ✅ Built-in | ❌ Not available |
| **CSI Validation** | ✅ Built-in | ❌ Not available |
| **Learning Curve** | Low - beginner friendly | Higher - need FIO knowledge |
| **Flexibility** | Medium | Very high |
| **Best For** | Quick validation | Detailed analysis |

---

## Common Use Cases

### 1. Quick Storage Validation

```bash
# Check if storage class works and get basic performance
./kubestr fio --storageclass oci-bv
```

### 2. Compare Storage Classes

```bash
# Test multiple storage classes
./simple-kubestr-test.sh oci-bv
./simple-kubestr-test.sh oci-bv-high

# Compare JSON results
diff results/kubestr_oci-bv_*.json results/kubestr_oci-bv-high_*.json
```

### 3. Pre-Production Validation

```bash
# Validate storage before deploying databases
./kubestr fio --storageclass oci-bv --size 100Gi
./kubestr csicheck --storageclass oci-bv
./kubestr blockmount --storageclass oci-bv
```

---

## Cleanup

After running tests:

```bash
# kubestr creates resources in 'kubestr-test' namespace (or custom namespace)
kubectl delete namespace kubestr-test

# Or if you used custom namespace
kubectl delete namespace <your-namespace>
```

---

## Troubleshooting

### PVC Won't Provision

```bash
# Check storage class exists
kubectl get sc

# Check CSI driver pods
kubectl get pods -n kube-system | grep csi

# Check PVC events
kubectl describe pvc -n kubestr-test
```

### kubestr Command Not Found

```bash
# Make sure binary is executable
chmod +x kubestr

# Run with full path
./kubestr fio --storageclass oci-bv
```

### Permission Denied

```bash
# Check kubeconfig
echo $KUBECONFIG

# Verify cluster access
kubectl cluster-info

# Check permissions
kubectl auth can-i create pvc
```

---

## Advanced Usage

### Custom FIO Configuration

Create a custom FIO configuration file:

```ini
# custom-fio.ini
[global]
ioengine=libaio
direct=1
bs=4k
iodepth=32
runtime=120
time_based=1

[randread]
rw=randread
numjobs=8

[randwrite]
rw=randwrite
numjobs=8
```

Run with custom config:

```bash
./kubestr fio --storageclass oci-bv --fiofile custom-fio.ini
```

### Node Selector

Run tests on specific nodes:

```bash
./kubestr fio \
    --storageclass oci-bv \
    --nodeselector node-type=storage \
    --nodeselector zone=us-west-1a
```

---

## Integration with CI/CD

```bash
#!/bin/bash
# storage-validation.sh

# Run kubestr test
./kubestr fio --storageclass oci-bv --output json --outfile results.json

# Parse results and fail if performance is below threshold
READ_IOPS=$(jq '.FIOReport.IOPs.Read' results.json)
if [ "$READ_IOPS" -lt 50000 ]; then
    echo "Storage performance below threshold!"
    exit 1
fi

echo "Storage validation passed!"
```

---

## Resources

- **Kubestr GitHub**: https://github.com/kastenhq/kubestr
- **Documentation**: https://docs.kasten.io/latest/usage/kubestr.html
- **FIO Documentation**: https://fio.readthedocs.io/

---

## Comparison with FIO Testing

Both kubestr and manual FIO testing are included in this framework:

- **Use kubestr** for: Quick validation, CI/CD integration, snapshot testing
- **Use FIO** for: Detailed analysis, custom test scenarios, learning storage concepts

See `../FIO/` directory for manual FIO testing examples.
