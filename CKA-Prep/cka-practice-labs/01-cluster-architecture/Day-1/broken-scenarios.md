
# Day 1 – Broken Scenarios

## 🔴 Scenario 1 – kube-apiserver Stops

### Impact:
- kubectl commands fail.
- No new deployments possible.
- Controllers stop reconciling state.

---

## 🔴 Scenario 2 – etcd Failure

### Impact:
- Cluster state unavailable.
- API server cannot read/write data.
- Existing pods may continue running temporarily.

---

## 🔴 Scenario 3 – Corrupted Static Pod Manifest

### Impact:
- kubelet continuously tries to restart component.
- Control plane instability.
- Component may fail to start due to YAML error.

---

## 🔴 Scenario 4 – Node Misconfiguration

If control plane node resources are exhausted:
- Scheduler cannot schedule new pods.
- Performance degradation occurs.