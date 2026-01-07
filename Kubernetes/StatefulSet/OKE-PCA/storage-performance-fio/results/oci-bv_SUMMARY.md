# OKE Storage Performance Test Results

## oci-bv (Standard Block Volume)

**Test Date**: 2026-01-07 12:15:36 PM CST
**Storage Class**: oci-bv
**Volume Size**: 50Gi
**Cluster**: OKE on PCA X9-2

---

## Performance Summary

| Test Scenario | IOPS | Bandwidth | Avg Latency | p95 Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|-------------|
| **Random Read** (4K) | 67,800 | 265 MiB/s | 0.94 ms | 1.48 ms | 1.65 ms |
| **Random Write** (4K) | 31,300 | 122 MiB/s | 2.05 ms | 2.64 ms | 2.84 ms |
| **Sequential Read** (1M) | 1,895 | 1,895 MiB/s | 8.41 ms | 9.77 ms | 10.16 ms |
| **Sequential Write** (1M) | 985 | 985 MiB/s | 16.20 ms | 21.10 ms | 23.99 ms |
| **Mixed 70R/30W** (4K) | Read: 40,000<br>Write: 17,200 | Read: 156 MiB/s<br>Write: 67 MiB/s | Read: 1.01 ms<br>Write: 1.34 ms | Read: 1.53 ms<br>Write: 1.83 ms | Read: 1.78 ms<br>Write: 2.06 ms |

---

## Detailed Results

### Test 1: Random Read IOPS (4K blocks, 60s)

**Performance:**
- **IOPS**: 67,800
- **Bandwidth**: 265 MiB/s (278 MB/s)
- **Total Data Read**: 15.5 GiB

**Latency Distribution:**
- Average: 944 μs (0.944 ms)
- p50: 996 μs
- p95: 1,483 μs
- p99: 1,647 μs
- p99.9: 2,212 μs

**Analysis**: Outstanding read performance, far exceeding OCI standard volume specs (~3,000 IOPS for 50GB)

---

### Test 2: Random Write IOPS (4K blocks, 60s)

**Performance:**
- **IOPS**: 31,300
- **Bandwidth**: 122 MiB/s (128 MB/s)
- **Total Data Written**: 7,326 MiB

**Latency Distribution:**
- Average: 2,047 μs (2.05 ms)
- p50: 2,089 μs
- p95: 2,638 μs
- p99: 2,835 μs
- p99.9: 5,211 μs

**Analysis**: Excellent write performance, 10x better than expected for oci-bv standard

---

### Test 3: Sequential Read (1M blocks, 60s)

**Performance:**
- **IOPS**: 1,895
- **Bandwidth**: 1,895 MiB/s (1.85 GiB/s)
- **Total Data Read**: 111 GiB

**Latency Distribution:**
- Average: 8.44 ms
- p50: 8.16 ms
- p95: 9.77 ms
- p99: 10.16 ms

**Analysis**: Exceptional sequential read throughput, ideal for large file operations, backups, and batch processing

---

### Test 4: Sequential Write (1M blocks, 60s)

**Performance:**
- **IOPS**: 985
- **Bandwidth**: 985 MiB/s (1,033 MB/s)
- **Total Data Written**: 57.7 GiB

**Latency Distribution:**
- Average: 16.24 ms
- p50: 16.06 ms
- p95: 21.10 ms
- p99: 23.99 ms

**Analysis**: Strong sequential write performance, suitable for logging, data ingestion, and backup operations

---

### Test 5: Mixed Workload (70% Read / 30% Write, 4K blocks, 60s)

**Read Performance:**
- **IOPS**: 40,000
- **Bandwidth**: 156 MiB/s
- **Total Data Read**: 9,378 MiB
- **Average Latency**: 1.01 ms
- **p95 Latency**: 1.53 ms
- **p99 Latency**: 1.78 ms

**Write Performance:**
- **IOPS**: 17,200
- **Bandwidth**: 67.2 MiB/s
- **Total Data Written**: 4,030 MiB
- **Average Latency**: 1.34 ms
- **p95 Latency**: 1.83 ms
- **p99 Latency**: 2.06 ms

**Analysis**: Demonstrates strong performance under realistic mixed workload conditions, typical for database and application servers

---

## Comparison with OCI Specifications

### Expected Performance for oci-bv (50GB volume):
- **IOPS**: ~3,000 (60 IOPS/GB × 50GB)
- **Throughput**: ~24 MB/s (480 KB/s/GB × 50GB)

### Actual Performance:
- **Random Read IOPS**: 67,800 **(22x better!)**
- **Random Write IOPS**: 31,300 **(10x better!)**
- **Sequential Read**: 1,895 MiB/s **(78x better!)**
- **Sequential Write**: 985 MiB/s **(40x better!)**

---

## Key Findings

✅ **Exceptional Performance**: All metrics significantly exceed OCI published specifications

✅ **Low Latency**: Sub-millisecond average latency for random reads

✅ **High Throughput**: Near 2 GB/s sequential read speed

✅ **Consistent Performance**: Stable results across all test scenarios

✅ **Production Ready**: Performance is suitable for demanding database workloads

---

## Workload Recommendations

| Workload Type | Suitability | Notes |
|---------------|-------------|-------|
| **MySQL/PostgreSQL (Dev/Test)** | ✅ Excellent | High IOPS and low latency |
| **MySQL/PostgreSQL (Production)** | ✅ Excellent | Performance exceeds typical prod requirements |
| **MongoDB** | ✅ Excellent | Random I/O performance is outstanding |
| **Redis/Memcached** | ✅ Excellent | Sub-millisecond latency |
| **Prometheus/Monitoring** | ✅ Excellent | High write throughput |
| **Application Logs** | ✅ Excellent | Sequential write performance is strong |
| **Backup/Restore** | ✅ Excellent | High sequential throughput |
| **Data Analytics** | ✅ Excellent | Strong sequential read/write |

---

## Cost-Performance Analysis

**Verdict**: oci-bv provides **exceptional value**
- Performance far exceeds standard block volume specifications
- Suitable for production database workloads
- oci-bv-high may only be needed for extremely high-concurrency scenarios

---

## Technical Details

**Test Configuration:**
- **Tool**: FIO 3.6
- **Engine**: libaio (Linux native async I/O)
- **I/O Depth**: 16
- **Jobs**: 4 (for random tests), 1 (for sequential tests)
- **Runtime**: 60 seconds per test
- **Direct I/O**: Enabled (bypasses OS cache)
- **Block Sizes**: 4K (IOPS tests), 1M (throughput tests)

**Storage Details:**
- **Volume OCID**: csi-7660f9a8-f41d-4d17-b42b-67290602ca8a
- **Provisioner**: blockvolume.csi.oraclecloud.com
- **Attachment Type**: Paravirtualized
- **Node**: oke-bb26b68d8f844f88b13f3fa3ad8f3085-scp1dbia8y2t13u0hbwy669cc2

---

## Conclusions

1. **Performance Excellence**: The oci-bv storage class delivers performance that far exceeds OCI's published standard block volume specifications

2. **Production Readiness**: With 67K+ read IOPS and sub-millisecond latency, this storage is production-ready for most database workloads

3. **Cost Optimization**: Given these results, oci-bv provides excellent value and may eliminate the need for oci-bv-high in many scenarios

4. **Recommendation**: oci-bv is recommended as the default storage class for most workloads unless oci-bv-high tests reveal specific benefits for ultra-high-concurrency scenarios

---

**Next Steps:**
1. Run identical tests on oci-bv-high storage class
2. Compare oci-bv vs oci-bv-high performance
3. Finalize workload-specific recommendations
4. Prepare client-facing performance report

---

**Raw Results File**: `oci-bv_20260107_121513.txt`
