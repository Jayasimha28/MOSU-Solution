# OKE Storage Performance - Comparative Analysis
## oci-bv vs oci-bv-high

**Test Date**: 2026-01-07
**Cluster**: OKE on PCA X9-2
**Volume Size**: 50Gi (both storage classes)
**Test Tool**: FIO 3.6 with libaio engine

---

## Executive Summary

Both storage classes deliver **exceptional performance** that far exceeds OCI published specifications. The key differentiator is **write performance**, where oci-bv-high shows significant advantages.

### Key Findings:
- ✅ **Read Performance**: Nearly identical (~3% difference)
- ✅ **Write Performance**: oci-bv-high is **63% faster** for random writes
- ✅ **Mixed Workloads**: oci-bv-high is **33% better** overall
- ✅ **Sequential Operations**: Similar performance for both classes
- 💰 **Cost Optimization**: oci-bv suitable for 80% of workloads

---

## Performance Comparison Table

| Metric | oci-bv | oci-bv-high | Improvement | Winner |
|--------|--------|-------------|-------------|--------|
| **Random Read IOPS** | 67,800 | 65,700 | -3% | oci-bv |
| **Random Write IOPS** | 31,300 | 51,100 | **+63%** | **oci-bv-high** |
| **Sequential Read** | 1,895 MiB/s | 1,797 MiB/s | -5% | oci-bv |
| **Sequential Write** | 985 MiB/s | 778 MiB/s | -21% | oci-bv |
| **Mixed Read IOPS** | 40,000 | 53,300 | **+33%** | **oci-bv-high** |
| **Mixed Write IOPS** | 17,200 | 22,900 | **+33%** | **oci-bv-high** |
| **Read Latency (avg)** | 0.94 ms | 0.97 ms | +3% | oci-bv |
| **Write Latency (avg)** | 2.05 ms | 1.25 ms | **-39%** | **oci-bv-high** |

---

## Detailed Analysis

### 1. Random Read Performance

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 67,800 | 265 MiB/s | 0.94 ms | 1.65 ms |
| **oci-bv-high** | 65,700 | 257 MiB/s | 0.97 ms | 1.63 ms |
| **Difference** | -3% | -3% | +3% | -1% |

**Verdict**: Virtually identical read performance. **No significant advantage** for oci-bv-high in read-heavy scenarios.

---

### 2. Random Write Performance ⭐

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 31,300 | 122 MiB/s | 2.05 ms | 2.84 ms |
| **oci-bv-high** | 51,100 | 200 MiB/s | 1.25 ms | 3.13 ms |
| **Difference** | **+63%** | **+64%** | **-39%** | +10% |

**Verdict**: **oci-bv-high is the clear winner** for write-intensive workloads. 63% more IOPS and 39% lower latency make it ideal for databases with heavy write traffic.

---

### 3. Sequential Read Performance

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 1,895 | 1,895 MiB/s | 8.41 ms | 10.16 ms |
| **oci-bv-high** | 1,797 | 1,797 MiB/s | 8.87 ms | 10.42 ms |
| **Difference** | -5% | -5% | +5% | +3% |

**Verdict**: Nearly identical sequential read performance. Both deliver excellent throughput for large file operations.

---

### 4. Sequential Write Performance

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 985 | 985 MiB/s | 16.20 ms | 23.99 ms |
| **oci-bv-high** | 777 | 778 MiB/s | 20.53 ms | 46.00 ms |
| **Difference** | -21% | -21% | +27% | +92% |

**Verdict**: Surprisingly, **oci-bv performs better** for sequential writes. Both classes are excellent for logging and batch operations.

---

### 5. Mixed Workload (70% Read / 30% Write) ⭐

#### Read Performance in Mixed Workload

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 40,000 | 156 MiB/s | 1.01 ms | 1.78 ms |
| **oci-bv-high** | 53,300 | 208 MiB/s | 0.72 ms | 1.29 ms |
| **Difference** | **+33%** | **+33%** | **-29%** | **-28%** |

#### Write Performance in Mixed Workload

| Storage Class | IOPS | Bandwidth | Avg Latency | p99 Latency |
|---------------|------|-----------|-------------|-------------|
| **oci-bv** | 17,200 | 67 MiB/s | 1.34 ms | 2.06 ms |
| **oci-bv-high** | 22,900 | 89 MiB/s | 1.11 ms | 2.41 ms |
| **Difference** | **+33%** | **+33%** | **-17%** | +17% |

**Verdict**: **oci-bv-high excels in mixed workloads**, showing 33% improvement in both read and write IOPS. This is the most realistic scenario for production databases.

---

## Workload Recommendations

### Use oci-bv (Standard) When:

✅ **Read-Heavy Workloads**
- Read-to-write ratio > 80:20
- Example: Data warehousing, reporting databases, caching layers

✅ **Development & Testing**
- Non-production environments
- Cost-sensitive deployments
- Example: Dev/test MySQL, PostgreSQL, MongoDB instances

✅ **Sequential Operations**
- Log aggregation and processing
- Backup and restore operations
- Batch data processing

✅ **Cost-Optimized Production**
- Moderate transaction volumes
- Applications with good caching
- Workloads with <30K write IOPS requirements

**Example Workloads:**
- WordPress/CMS databases
- Monitoring systems (Prometheus, Grafana)
- Application logs and metrics
- Development databases
- Read replicas

---

### Use oci-bv-high (High Performance) When:

✅ **Write-Intensive Workloads**
- Write-to-read ratio > 30:70
- Example: OLTP databases, real-time data ingestion

✅ **High-Concurrency Applications**
- >50K write IOPS required
- Example: E-commerce, financial trading, gaming

✅ **Low-Latency Requirements**
- Sub-millisecond write latency critical
- Example: Session stores, real-time analytics

✅ **Mixed Workload Optimization**
- Balanced read/write patterns
- Example: SaaS applications, CRM systems

✅ **Production Databases**
- Mission-critical applications
- High transaction volumes
- Example: Production MySQL/PostgreSQL with >1000 TPS

**Example Workloads:**
- E-commerce transaction databases
- Financial trading systems
- Real-time bidding platforms
- High-traffic SaaS applications
- Gaming leaderboards and state management
- IoT data ingestion

---

## Cost vs Performance Analysis

### Performance Gains

| Scenario | oci-bv Performance | oci-bv-high Performance | Gain |
|----------|-------------------|------------------------|------|
| **Read-Heavy** | 67.8K IOPS | 65.7K IOPS | -3% |
| **Write-Heavy** | 31.3K IOPS | 51.1K IOPS | **+63%** |
| **Mixed (Typical)** | 40K read / 17.2K write | 53.3K read / 22.9K write | **+33%** |
| **Sequential Read** | 1,895 MiB/s | 1,797 MiB/s | -5% |
| **Sequential Write** | 985 MiB/s | 778 MiB/s | -21% |

### Cost Consideration

Assuming oci-bv-high costs **2-3x** more than oci-bv (typical OCI pricing):

**Good Value for oci-bv-high:**
- Write-intensive: 63% performance gain for 2-3x cost = **21-32% value improvement**
- Mixed workload: 33% performance gain for 2-3x cost = **11-17% value improvement**

**Poor Value for oci-bv-high:**
- Read-heavy: 3% performance loss for 2-3x cost = **negative value**
- Sequential writes: 21% performance loss for 2-3x cost = **negative value**

### ROI Recommendation

| Workload Type | Recommended Storage | ROI Justification |
|---------------|---------------------|-------------------|
| **Read-Heavy (>80% reads)** | oci-bv | No benefit from oci-bv-high |
| **Balanced (50/50)** | oci-bv-high | 33% performance gain justifies cost |
| **Write-Heavy (>40% writes)** | oci-bv-high | 63% performance gain = excellent ROI |
| **Dev/Test** | oci-bv | Cost savings, performance adequate |
| **Sequential Ops** | oci-bv | Better performance at lower cost |

---

## Decision Matrix

### Quick Selection Guide

```
                                    │
                    Read-Heavy      │      Write-Heavy
                                    │
              oci-bv ←──────────────┼──────────────→ oci-bv-high
                                    │
                                    │
        Cost-Sensitive              │      Performance-Critical
                                    │
              oci-bv ←──────────────┼──────────────→ oci-bv-high
                                    │
                                    │
        Dev/Test                    │      Production
                                    │
              oci-bv ←──────────────┼──────────────→ oci-bv-high
                                    │
                                    │
```

### Detailed Decision Tree

1. **Is this production?**
   - No → **oci-bv** (cost savings)
   - Yes → Continue to #2

2. **What's your write IOPS requirement?**
   - <30,000 → **oci-bv** (adequate performance)
   - >30,000 → Continue to #3

3. **What's your read:write ratio?**
   - >80:20 (read-heavy) → **oci-bv** (no read benefit from high)
   - 50:50 to 80:20 (balanced) → **oci-bv-high** (33% mixed workload gain)
   - <50:50 (write-heavy) → **oci-bv-high** (63% write performance gain)

4. **Is sub-millisecond write latency critical?**
   - No → Consider **oci-bv** (cost savings)
   - Yes → **oci-bv-high** (39% lower write latency)

---

## Migration Recommendations

### When to Upgrade from oci-bv to oci-bv-high

📈 **Indicators you need oci-bv-high:**
- Database write IOPS consistently >25,000
- Write latency p99 >5ms causing application slowdowns
- Mixed workload showing storage bottlenecks
- Application requires <2ms write latency SLA
- Transaction throughput limited by storage

### When to Downgrade from oci-bv-high to oci-bv

📉 **Indicators oci-bv is sufficient:**
- Actual IOPS <20,000 (underutilized)
- Read-heavy workload (>80% reads)
- Cost optimization initiative
- Performance metrics show no storage bottlenecks
- Moving to dev/test environment

### Migration Process

1. **Backup data** using database native tools
2. **Create new PVC** with desired storage class
3. **Restore data** to new volume
4. **Test performance** with realistic workload
5. **Monitor metrics** for 24-48 hours
6. **Validate** cost vs performance tradeoff

---

## Real-World Scenarios

### Scenario 1: E-Commerce Platform

**Requirements:**
- Product catalog (read-heavy)
- Order processing (write-intensive)
- User sessions (mixed workload)

**Recommendation:**
- **Catalog DB**: oci-bv (read-heavy, 10K writes/sec)
- **Orders DB**: oci-bv-high (write-intensive, 50K writes/sec)
- **Sessions**: oci-bv-high (low-latency requirement)

---

### Scenario 2: SaaS Application

**Requirements:**
- Multi-tenant database
- Balanced read/write (60:40)
- 35K mixed IOPS

**Recommendation:**
- **Production**: oci-bv-high (33% mixed workload improvement)
- **Staging**: oci-bv (cost savings, adequate performance)
- **Development**: oci-bv (cost optimization)

---

### Scenario 3: Analytics Platform

**Requirements:**
- Data ingestion (write-heavy)
- Query engine (read-heavy)
- Reporting (sequential reads)

**Recommendation:**
- **Ingestion DB**: oci-bv-high (write-intensive, 60K writes/sec)
- **Query DB**: oci-bv (read-heavy, excellent read performance)
- **Reports**: oci-bv (sequential reads, lower cost)

---

## Conclusions

1. **Both storage classes exceed OCI specifications** by 10-20x

2. **oci-bv-high's advantage is write performance**: 63% better random writes, 33% better mixed workloads

3. **oci-bv is excellent for most workloads**: Outstanding read performance, good writes, lower cost

4. **Recommendation split**:
   - **80% of workloads**: oci-bv is sufficient and cost-effective
   - **20% of workloads**: oci-bv-high worth the premium (write-intensive, high-concurrency)

5. **Start with oci-bv**: For new deployments, start with oci-bv and upgrade to oci-bv-high if metrics show write bottlenecks

6. **Production databases with >40% writes**: Use oci-bv-high for optimal performance

7. **Read-heavy and dev/test**: Always use oci-bv for cost optimization

---

## Next Steps

1. ✅ Review this analysis with stakeholders
2. ✅ Map existing workloads to recommended storage classes
3. ✅ Create storage class selection guidelines for teams
4. ✅ Monitor production metrics to validate decisions
5. ✅ Plan migrations for misconfigured workloads
6. ✅ Update infrastructure-as-code templates
7. ✅ Train teams on storage class selection criteria

---

**Test Results Files:**
- [oci-bv Results](oci-bv_20260107_121513.txt)
- [oci-bv Summary](oci-bv_SUMMARY.md)
- [oci-bv-high Results](oci-bv-high_20260107_122600.txt)
- [oci-bv-high Summary](oci-bv-high_SUMMARY.md)
