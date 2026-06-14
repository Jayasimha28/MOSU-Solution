# Task 04 — Deployments with Resource Limits

**CKA Domain:** Workloads & Scheduling (15%) · Cluster Architecture (25%)  
**Week:** 01 · **Difficulty:** Foundational  
**Date:** 2026-06-08

---

## Objective

Generate a Deployment manifest using imperative `--dry-run`, add resource requests and limits manually, and apply it to a dedicated namespace.

---

## Concepts Covered

- `kubectl create deployment` with `--dry-run=client -o yaml`
- Resource `requests` vs `limits` — why both matter
- Namespace creation before manifest apply
- YAML stub cleanup (`resources: {}`, `status: {}`)
- Verifying resource limits with `kubectl describe`

---

## Key Commands

```bash
# 1. Create namespace first — always
kubectl create ns production

# 2. Generate base YAML — never write from scratch
kubectl create deployment api-deploy \
  --image=nginx:1.25 \
  --replicas=3 \
  -n production \
  --dry-run=client -o yaml > api-deploy.yaml

# 3. Clean generated stubs before editing
sed -i '/strategy: {}\|status: {}/d' api-deploy.yaml

# 4. Apply
kubectl apply -f api-deploy.yaml

# 5. Verify resources landed correctly
kubectl describe deploy api-deploy -n production | grep -A5 'Limits\|Requests'
```

---

## Final Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: api-deploy
  name: api-deploy
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-deploy
  template:
    metadata:
      labels:
        app: api-deploy
    spec:
      containers:
      - image: nginx:1.25
        name: nginx
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
```

---

## Verify Output

```
NAME         READY   UP-TO-DATE   AVAILABLE
api-deploy   3/3     3            3

Limits:
  cpu:     200m
  memory:  256Mi
Requests:
  cpu:     100m
  memory:  128Mi
```

---

## Exam Tips

| Tip | Why It Matters |
|-----|----------------|
| Always `create ns` before applying manifests | Manifest has namespace in spec — apply fails if ns missing |
| Use `--dry-run=client -o yaml` as your starting point | Faster and less error-prone than writing YAML from scratch |
| Delete `resources: {}` stub after generating | Duplicate YAML keys silently overwrite your values |
| Use `describe \| grep -A5 'Limits\|Requests'` to verify | Confirms limits landed — don't assume, always verify |
| `--force --grace-period=0` for immediate pod deletion | Default graceful termination waits 30s — too slow on exam |

---

## Requests vs Limits — Quick Reference

| Field | Purpose | What happens if exceeded |
|-------|---------|--------------------------|
| `requests.cpu` | Minimum CPU guaranteed for scheduling | Pod may not be scheduled if node lacks it |
| `requests.memory` | Minimum memory guaranteed | Pod may not be scheduled if node lacks it |
| `limits.cpu` | Maximum CPU the container can use | Container is throttled (not killed) |
| `limits.memory` | Maximum memory the container can use | Container is OOMKilled if exceeded |

---

## Common Mistakes

```bash
# ❌ Wrong — apply before creating namespace
kubectl apply -f api-deploy.yaml
# Error from server (NotFound): namespaces "production" not found

# ✅ Correct — namespace first
kubectl create ns production
kubectl apply -f api-deploy.yaml

# ❌ Wrong — duplicate resources key left in YAML
resources:
  requests:
    cpu: "100m"
resources: {}   # ← silently overwrites your values

# ✅ Correct — single resources block, no stubs
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"
```

---

## Related Tasks

- [task-01-pods](../task-01-pods/) — Pod creation basics
- [task-02-deployments](../task-02-deployments/) — Deployment fundamentals
- [task-03-services](../task-03-services/) — Exposing workloads

---

*Part of [cka-prep-2026](../../README.md) — CKA exam preparation repository*