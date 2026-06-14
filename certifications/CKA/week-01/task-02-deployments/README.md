# Task 02 - Deployments

## Objective

Create a Deployment named `webapp` using the `nginx:latest` image and scale it to 3 replicas.

---

## Create Deployment

Imperative command:

```bash
kubectl create deployment webapp \
  --image=nginx:latest
```

---

## Generate YAML

```bash
kubectl create deployment webapp \
  --image=nginx:latest \
  --dry-run=client \
  -o yaml > deployment.yaml
```

---

## Apply Deployment

```bash
kubectl apply -f deployment.yaml
```

---

## Verify Deployment

```bash
kubectl get deployment

kubectl get pods

kubectl get rs
```

---

## Scale Deployment

```bash
kubectl scale deployment webapp \
  --replicas=3
```

Verify:

```bash
kubectl get pods
```

---

## Deployment Architecture

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
```

---

## Pod vs Deployment

### Pod

- Smallest deployable unit in Kubernetes.
- Runs one or more containers.
- Does not provide self-healing by itself.

### Deployment

- Manages Pods using a ReplicaSet.
- Supports scaling.
- Supports rolling updates.
- Automatically recreates failed Pods.

---

## Learning

- Deployments are the preferred way to run stateless applications.
- ReplicaSets ensure the desired number of Pods are running.
- Scaling a Deployment updates the ReplicaSet.
- Deployments provide self-healing and rolling updates.

---

## Verification

```bash
kubectl get deployment

kubectl get pods

kubectl get rs
```

Expected result:

```text
Deployment: webapp

Replicas: 3

Pods Running: 3
```

---

## CKA Exam Notes

Useful commands:

```bash
kubectl create deployment webapp --image=nginx

kubectl scale deployment webapp --replicas=3

kubectl rollout status deployment/webapp

kubectl get rs

kubectl get deployment
```