# Kubernetes Storage Performance Testing

Two independent frameworks for testing storage performance on Kubernetes clusters.

---

## 📁 Testing Frameworks

### 1. FIO Testing (Manual Control)
**Directory**: `FIO/`

Manual FIO-based storage performance testing with full control over test parameters.

- ✅ Complete control over test scenarios
- ✅ Industry-standard benchmarking
- ✅ Detailed results and analysis
- ✅ Client-ready performance reports
- ✅ Manual testing procedures for demos

**Quick Start**:
```bash
cd FIO
export KUBECONFIG=/path/to/kubeconfig
./simple-fio-test.sh <storage-class>
```

**Documentation**: See [FIO/README.md](FIO/README.md)

---

### 2. Kubestr Testing (Automated)
**Directory**: `kubestr/`

Automated storage performance testing using kubestr tool.

- ✅ One-command testing
- ✅ JSON output format
- ✅ Snapshot testing support
- ✅ CSI validation
- ✅ Quick validation

**Quick Start**:
```bash
cd kubestr
export KUBECONFIG=/path/to/kubeconfig
./simple-kubestr-test.sh <storage-class>
```

**Documentation**: See [kubestr/KUBESTR_README.md](kubestr/KUBESTR_README.md)

---

## 🎯 Which One to Use?

| Use Case | Recommended |
|----------|-------------|
| Learning & Teaching | FIO |
| Quick Validation | Kubestr |
| Detailed Analysis | FIO |
| CI/CD Integration | Kubestr |
| Custom Test Scenarios | FIO |
| Snapshot Testing | Kubestr |

---

## 📊 Requirements

- kubectl installed
- Valid KUBECONFIG
- Permissions to create namespaces, PVCs, and pods
- For FIO: No additional tools (runs in container)
- For kubestr: Binary included in kubestr/ directory

---

## 🌐 Supported Platforms

Both frameworks work on any Kubernetes cluster with CSI storage:
- Oracle Kubernetes Engine (OKE)
- AWS EKS
- Azure AKS
- Google GKE
- Local K8s (Minikube, Kind, K3s)
- On-premises Kubernetes

---

Choose the framework that fits your needs. Both are independent and can be used separately.
