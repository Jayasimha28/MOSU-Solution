# Kubestr Storage Performance Test Results

**Test Date**: January 7, 2026
**Cluster**: Oracle Kubernetes Engine (OKE) on PCA X9-2
**Volume Size**: 50Gi
**Tool**: kubestr v0.4.49 with FIO 3.36

---

## Test Configuration

Kubestr runs a default FIO test profile with:
- **Test Duration**: 15 seconds per test (+ 2s ramp time)
- **Block Sizes**: 4K (IOPS tests), 128K (bandwidth tests)
- **I/O Depth**: 64
- **File Size**: 2G
- **Engine**: libaio (Linux native async I/O)
- **Direct I/O**: Enabled

### Tests Run:
1. Random Read IOPS (4K blocks)
2. Random Write IOPS (4K blocks)
3. Random Read Bandwidth (128K blocks)
4. Random Write Bandwidth (128K blocks)

---

## Results Summary

| Test | oci-bv | oci-bv-high | Difference |
|------|--------|-------------|------------|
| **Random Read IOPS** (4K) | 5,397 | 5,666 | +5.0% |
| **Random Write IOPS** (4K) | 2,792 | 2,874 | +2.9% |
| **Random Read Bandwidth** (128K) | 805 MiB/s | 842 MiB/s | +4.6% |
| **Random Write Bandwidth** (128K) | 398 MiB/s | 415 MiB/s | +4.3% |

---

## Detailed Results

### oci-bv (Standard Block Volume)

#### Random Read IOPS (4K blocks)
- **IOPS**: 5,397
- **Bandwidth**: 21,606 KiB/s (21.1 MiB/s)
- **Range**: 4,548 - 7,144 IOPS

#### Random Write IOPS (4K blocks)
- **IOPS**: 2,792
- **Bandwidth**: 11,183 KiB/s (10.9 MiB/s)
- **Range**: 2,192 - 3,540 IOPS

#### Random Read Bandwidth (128K blocks)
- **IOPS**: 6,287
- **Bandwidth**: 805,317 KiB/s (786 MiB/s)
- **Range**: 5,204 - 7,993 IOPS

#### Random Write Bandwidth (128K blocks)
- **IOPS**: 3,109
- **Bandwidth**: 398,453 KiB/s (389 MiB/s)
- **Range**: 2,544 - 4,030 IOPS

---

### oci-bv-high (High-Performance Block Volume)

#### Random Read IOPS (4K blocks)
- **IOPS**: 5,666
- **Bandwidth**: 22,681 KiB/s (22.1 MiB/s)
- **Range**: 4,720 - 6,732 IOPS

#### Random Write IOPS (4K blocks)
- **IOPS**: 2,874
- **Bandwidth**: 11,513 KiB/s (11.2 MiB/s)
- **Range**: 2,326 - 3,498 IOPS

#### Random Read Bandwidth (128K blocks)
- **IOPS**: 6,576
- **Bandwidth**: 842,263 KiB/s (822 MiB/s)
- **Range**: 5,296 - 8,126 IOPS

#### Random Write Bandwidth (128K blocks)
- **IOPS**: 3,234
- **Bandwidth**: 414,531 KiB/s (405 MiB/s)
- **Range**: 2,590 - 3,892 IOPS

---

## Analysis

### Key Findings

✅ **Similar Performance**: Both storage classes show very similar performance with kubestr's default test

✅ **Slight Advantage for oci-bv-high**: 3-5% better across all metrics

✅ **Both Exceed OCI Specs**: Performance significantly exceeds published specifications

⚠️ **Different from FIO Results**: Kubestr results show smaller differences compared to our detailed FIO tests

### Why Different from FIO Results?

The kubestr results show smaller performance differences compared to FIO tests because:

1. **Shorter Test Duration**: 15 seconds vs 60 seconds (FIO)
   - Less time for storage to reach steady-state performance
   - More variability in results

2. **Different Test Parameters**:
   - kubestr: 128K blocks for bandwidth tests
   - FIO: 1M blocks for sequential tests
   - Different block sizes produce different results

3. **Test Focus**:
   - kubestr: Random operations only
   - FIO: Both random and sequential operations

4. **Workload Intensity**:
   - kubestr: Single job per test
   - FIO: Multiple parallel jobs (4 jobs for random tests)

---

## Comparison: Kubestr vs FIO Results

| Metric | Kubestr oci-bv | FIO oci-bv | Kubestr oci-bv-high | FIO oci-bv-high |
|--------|----------------|------------|---------------------|-----------------|
| **Random Read IOPS** | 5,397 | 67,800 | 5,666 | 65,700 |
| **Random Write IOPS** | 2,792 | 31,300 | 2,874 | 51,100 |

**Why the huge difference?**
- FIO tests use 4 parallel jobs with higher I/O depth
- Longer test duration (60s vs 15s)
- Different test methodology

---

## Recommendations

### Use Kubestr For:
✅ Quick validation that storage is working
✅ CI/CD pipeline checks
✅ Baseline performance verification
✅ Comparing multiple storage classes quickly

### Use FIO (detailed tests) For:
✅ Production readiness validation
✅ Detailed performance analysis
✅ Capacity planning
✅ Understanding storage behavior under load
✅ Client-facing performance reports

---

## Kubestr Test Parameters

```ini
[global]
randrepeat=0
verify=0
ioengine=libaio
direct=1
gtod_reduce=1

[job1]
name=read_iops
bs=4K
iodepth=64
size=2G
readwrite=randread
time_based
ramp_time=2s
runtime=15s

[job2]
name=write_iops
bs=4K
iodepth=64
size=2G
readwrite=randwrite
time_based
ramp_time=2s
runtime=15s

[job3]
name=read_bw
bs=128K
iodepth=64
size=2G
readwrite=randread
time_based
ramp_time=2s
runtime=15s

[job4]
name=write_bw
bs=128k
iodepth=64
size=2G
readwrite=randwrite
time_based
ramp_time=2s
runtime=15s
```

---

## Conclusions

1. **Kubestr is great for quick validation** - Results show storage is performing well

2. **Both storage classes are similar** in kubestr's default test (3-5% difference)

3. **For detailed analysis, use FIO** - FIO tests revealed the 63% write performance advantage of oci-bv-high

4. **Kubestr complements FIO** - Use kubestr for quick checks, FIO for detailed analysis

5. **Both tools are valuable** - They serve different purposes in your testing toolkit

---

## Raw Results Files

- **oci-bv**: [oci-bv_20260107.json](oci-bv_20260107.json)
- **oci-bv-high**: [oci-bv-high_20260107.json](oci-bv-high_20260107.json)

View with: `cat results/oci-bv_20260107.json | jq .`

---

**Kubestr testing completed successfully. For detailed performance analysis, refer to the FIO test results.**
