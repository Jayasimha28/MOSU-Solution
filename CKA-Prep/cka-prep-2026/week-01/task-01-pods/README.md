# Task 01 - Create a Pod

## Objective

Create a Pod named `nginx-pod` using the `nginx` image.

## Commands Used

```bash
kubectl run nginx-pod --image=nginx

kubectl get pods

kubectl describe pod nginx-pod

kubectl run nginx-pod \
  --image=nginx \
  --dry-run=client \
  -o yaml > nginx-pod.yaml
```

## Verification

```bash
kubectl get pods
```

Expected output:

```text
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          1m
```

## Learning

* A Pod is the smallest deployable unit in Kubernetes.
* `kubectl run` can be used to create a Pod imperatively.
* `kubectl describe` provides detailed runtime information.
* `--dry-run=client -o yaml` is useful for generating manifests during the CKA exam.

## CKA Notes

Using imperative commands and exporting YAML is often faster than writing manifests from scratch during the exam.
