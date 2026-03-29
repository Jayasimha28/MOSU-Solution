# Day 1 – Kubernetes Cluster Architecture

## 🎯 Objective

Build a local Kubernetes cluster and understand how the control plane operates.

Focus:
- Cluster creation using kind
- Control plane components
- Static Pods
- kube-system namespace inspection

---

## 🛠 Lab Steps Overview

1. Create a kind cluster
2. Verify cluster connectivity
3. Inspect node details
4. Explore kube-system namespace
5. Identify control plane components
6. Inspect static pod manifests

---

## 🔍 Observations

- Control plane components run as static pods.
- Static pod manifests exist in `/etc/kubernetes/manifests`.
- kube-apiserver is the central communication hub.
- etcd stores the entire cluster state.
- kubelet watches manifest directory and recreates pods if changed.

---

## 🧠 Key Learnings

- If kube-apiserver fails → kubectl stops working.
- If etcd fails → cluster state becomes unavailable.
- Static pods are directly managed by kubelet.
- Understanding control plane is critical for troubleshooting.

---

## 🚀 Production Relevance

- Essential for disaster recovery.
- Helps debug cluster outages.
- Important for etcd backup/restore.
- Critical knowledge for CKA exam.