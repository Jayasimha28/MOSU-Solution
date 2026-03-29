# Day 1 – Commands Used

## 1️⃣ Create Cluster

```bash
kind create cluster --name cka-day1
```

## 2️⃣ Verify Cluster
```bash
kubectl cluster-info
kubectl get nodes
```

## 3️⃣ Inspect Node Details

```bash
kubectl describe node <node-name>
```

## 4️⃣ List kube-system Pods
```bash
kubectl get pods -n kube-system
```

## 5️⃣ Describe API Server Pod

```bash
kubectl describe pod <kube-apiserver-pod-name> -n kube-system
```

## 6️⃣ Check Running Containers (kind uses Docker)
```bash
docker ps
```

## 7️⃣ Inspect Static Pod Manifests
```bash
docker exec -it <control-plane-container-name> ls /etc/kubernetes/manifests
```