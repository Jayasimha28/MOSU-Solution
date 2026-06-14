# Task 03 - Services

## Objective

Expose the `webapp` Deployment using a ClusterIP Service.

---

## Create Service

Imperative command:

```bash
kubectl expose deployment webapp \
  --name=webapp-svc \
  --port=80 \
  --target-port=80
```

---

## Generate YAML

```bash
kubectl expose deployment webapp \
  --name=webapp-svc \
  --port=80 \
  --target-port=80 \
  --dry-run=client \
  -o yaml > service.yaml
```

---

## Verify Service

```bash
kubectl get svc

kubectl describe svc webapp-svc
```

---

## Verify Endpoints

```bash
kubectl get endpoints

kubectl get ep
```

---

## Test Connectivity

Create a temporary pod:

```bash
kubectl run test-pod \
  --image=busybox \
  --restart=Never \
  -it --rm -- sh
```

Inside the pod:

```sh
wget -qO- http://webapp-svc

nslookup webapp-svc
```

---

## Learning

### Why Services Are Needed

Pod IPs are temporary and may change when Pods are recreated.

Services provide:

* Stable virtual IP
* Stable DNS name
* Load balancing across Pods

### Labels

Labels are key-value pairs attached to resources.

Example:

```yaml
app: webapp
```

### Selectors

Services use selectors to identify target Pods.

Example:

```yaml
selector:
  app: webapp
```

### Endpoints

Endpoints represent the actual Pod IPs behind a Service.

Example:

```text
10.244.0.8:80
10.244.0.9:80
10.244.0.10:80
```

---

## Verification

```bash
kubectl get svc

kubectl get endpoints
```

Expected result:

* Service created successfully
* Service has ClusterIP
* Endpoints point to all backend Pods
* DNS resolves correctly

---

## CKA Exam Notes

Useful commands:

```bash
kubectl expose deployment

kubectl get svc

kubectl describe svc

kubectl get endpoints

kubectl run test-pod \
  --image=busybox \
  --restart=Never \
  -it --rm -- sh
```
