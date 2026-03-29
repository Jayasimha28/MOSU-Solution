# ☸️ Kind Cluster Setup Guide (CKA Practice)

This guide helps you create and manage a Kubernetes cluster using Kind.

------------------------------------------------------------------------

## 📦 Prerequisites

-   Docker installed
-   kubectl installed
-   kind installed

------------------------------------------------------------------------

## 🔧 Install Kind

``` bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/
```

------------------------------------------------------------------------

## 🔧 Verify Installation

``` bash
kind version
kubectl version --client
```

------------------------------------------------------------------------

## 🏗 Create Cluster

``` bash
kind create cluster --name cka-day1
```

------------------------------------------------------------------------

## 🔍 Verify Cluster

``` bash
kubectl cluster-info --context kind-cka-day1
kubectl get nodes
```

------------------------------------------------------------------------

## 📄 Optional: Custom Cluster Config

Create file: kind-config.yaml

``` yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: cka-cluster
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Create cluster using config:

``` bash
kind create cluster --config kind-config.yaml
```

------------------------------------------------------------------------

## 🧪 Basic Commands

``` bash
kubectl get pods -A
kubectl get nodes
kubectl describe node <node-name>
```

------------------------------------------------------------------------

## 🛑 Delete Cluster

``` bash
kind delete cluster --name cka-day1
```

------------------------------------------------------------------------

## 🔄 Restart Cluster (Recreate)

``` bash
kind delete cluster --name cka-day1
kind create cluster --name cka-day1
```

------------------------------------------------------------------------

## 🚀 Next Step

Start Day 1 lab and begin CKA practice.
