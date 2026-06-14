# Task 01 - Pods

## Objective

Create a Pod named `nginx-test` using the `nginx` image.

---

## Create Pod

Imperative command:

```bash
kubectl run nginx-test --image=nginx
```

---

## Verify Pod

```bash
kubectl get pods

kubectl describe pod nginx-test
```

---

## Generate YAML

```bash
kubectl run nginx-test \
  --image=nginx \
  --dry-run=client \
  -o yaml > nginx-pod.yaml
```

---

## Apply YAML

```bash
kubectl apply -f nginx-pod.yaml
```

---

## Delete Pod

```bash
kubectl delete pod nginx-test
```

---

## Learning

- Pod is the smallest deployable unit in Kubernetes.
- A Pod can contain one or more containers.
- `kubectl run` can be used to create Pods imperatively.
- `kubectl describe` provides runtime information about a Pod.
- `--dry-run=client -o yaml` is useful for generating manifests.

---

## Verification

```bash
kubectl get pods
```

Expected output:

```text
NAME         READY   STATUS    RESTARTS   AGE
nginx-test   1/1     Running   0          XXs
```

---

## CKA Exam Notes

Useful commands:

```bash
kubectl run nginx-test --image=nginx

kubectl get pods

kubectl describe pod nginx-test

kubectl delete pod nginx-test

kubectl run nginx-test \
  --image=nginx \
  --dry-run=client \
  -o yaml
```