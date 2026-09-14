# Week 03 — Services & Networking

**CKA Domain:** Services & Networking (20%)
**Week:** 03 · **Score:** 12/12 (100%)
**Date:** 2026-09-15

---

## Tasks Completed

| Task | Topic | Score |
|------|-------|-------|
| task-01-service-types | NodePort Service | 4/4 |
| task-02-networkpolicy | Default-deny + scoped-allow NetworkPolicy | 4/4 |
| task-03-coredns | CoreDNS troubleshooting — broken Corefile | 4/4 |

---

## Task 01 — NodePort Service

### Objective
Create and verify a NodePort Service that exposes an application running in multiple Pods, and confirm traffic correctly routes to the backend Pods.

### Key Concept
A `NodePort` Service opens the same port on **every node in the cluster**, not just the node where a backend Pod happens to be running — kube-proxy handles routing from any node to the right Pod.

### Final Manifest
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: web
  name: web-node
  namespace: net-lab
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30080
  selector:
    app: web
  type: NodePort
```

### Exam-Efficient Approach
```bash
# Generate the skeleton from the existing Deployment instead of hand-writing it
kubectl expose deployment web -n net-lab \
  --type=NodePort --port=80 --target-port=80 \
  --dry-run=client -o yaml > web-node.yaml

# --node-port isn't a flag on `expose` — hand-edit the nodePort in afterward
vi web-node.yaml   # add: nodePort: 30080
kubectl apply -f web-node.yaml
```

### Verify
```bash
kubectl get svc -n net-lab
kubectl get endpoints web-node -n net-lab

# Actually test routing from a node, not just check the spec
docker exec cka-lab-control-plane curl -s -o /dev/null -w "HTTP:%{http_code}\n" http://localhost:30080
docker exec cka-lab-worker curl -s -o /dev/null -w "HTTP:%{http_code}\n" http://localhost:30080
```

Expected: `HTTP:200` from every node, and all backend Pod IPs listed under `ENDPOINTS`.

### Common Mistake
Recreating the Service via `kubectl expose deployment web` **without** `--name` silently names it after the Deployment (`web`) instead of the name the task actually required (`web-node`). On the real exam, a Service name mismatch like this costs points even if everything else is correct — always double-check the object name matches exactly what was asked, not just that *a* working Service exists.

---

## Task 02 — NetworkPolicy (Default-Deny + Scoped Allow)

### Objective
Create a default-deny NetworkPolicy for backend Pods, then allow only the required traffic using pod/namespace selectors. Prove that unauthorized traffic is blocked while explicitly permitted traffic still works.

### Key Concepts

**1. `ports` belongs at the ingress-rule level, not inside `from[]`**
```yaml
ingress:
- from:            # list of allowed sources
  - podSelector: {...}
  ports:            # sibling of `from`, NOT a member of the from[] list
  - protocol: TCP
    port: 80
```
Run `kubectl explain networkpolicy.spec.ingress` when unsure of the shape — faster than guessing under exam pressure.

**2. Separate `from` list items are OR'd, not AND'd**
```yaml
# WRONG — matches "any app=frontend pod in ANY namespace" OR
#         "any pod in a namespace labeled name=frontend" (two independent paths in)
from:
- podSelector:
    matchLabels:
      app: frontend
- namespaceSelector:
    matchLabels:
      kubernetes.io/metadata.name: frontend

# CORRECT — both conditions in the SAME from[] item = AND
# ("frontend pods, AND only within the frontend namespace")
from:
- podSelector:
    matchLabels:
      app: frontend
  namespaceSelector:
    matchLabels:
      kubernetes.io/metadata.name: frontend
```

**3. Namespaces aren't labeled `name=<ns>` automatically**
The only label every namespace gets for free is the built-in `kubernetes.io/metadata.name`. A `namespaceSelector` matching a plain `name:` label will silently match nothing unless you added that label yourself.
```bash
kubectl get ns frontend --show-labels
# kubernetes.io/metadata.name=frontend   ← this is the real one
```

### Final Manifests

`default-deny-ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

`allow-frontend-ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-ingress
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
      podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```

### Verify — Prove It, Don't Just Trust the YAML
```bash
# Allowed path — expect HTTP:200
kubectl exec -n frontend frontend-client -- \
  curl -s -o /dev/null -w "HTTP:%{http_code}\n" --max-time 5 \
  http://backend-api.backend.svc.cluster.local

# Blocked path — expect a timeout, not a clean rejection
kubectl exec -n default other-client -- \
  curl -s -o /dev/null -w "HTTP:%{http_code}\n" --max-time 5 \
  http://backend-api.backend.svc.cluster.local
```

### Diagnostic Signature Worth Remembering
A NetworkPolicy denial looks like a **silent timeout** (curl exit code 28, `HTTP:000`) — the SYN packet is just dropped, no RST, no rejection. If you instead see "connection refused" or an instant failure, that's a different problem (wrong port, Service doesn't exist) — not the policy working as intended.

---

## Task 03 — CoreDNS Troubleshooting

### Objective
Service name resolution was failing cluster-wide (direct ClusterIP access still worked). Diagnose the root cause, fix it, and verify DNS actually resolves again — not just that the pods look `Running`.

### Injected Fault
The `coredns` ConfigMap (`kube-system`) had a typo in the Corefile: the `kubernetes` plugin directive was misspelled `kubernetess`. CoreDNS pods were then forced to restart onto the broken config, putting them into `CrashLoopBackOff`.

### Diagnostic Workflow
```bash
# Pods crash-looping is the first signal — check why
kubectl get pods -n kube-system -l k8s-app=kube-dns

# The actual error is in the container logs, not `describe`
kubectl logs deploy/coredns -n kube-system
# /etc/coredns/Corefile:7 - Error during parsing: Unknown directive 'kubernetess'
```

### Fix
```bash
kubectl edit configmap coredns -n kube-system
# correct: kubernetess → kubernetes
```

### Key Concept — Why a Config Edit Alone Doesn't Fix It
The default Corefile includes the `reload` plugin, which watches the Corefile for changes and hot-reloads automatically — but only for pods that are **already running**. Pods stuck in `CrashLoopBackOff` aren't running long enough to watch anything; they need to be forced to restart so the corrected ConfigMap gets picked up fresh at startup.
```bash
kubectl rollout restart deployment/coredns -n kube-system
kubectl rollout status deployment/coredns -n kube-system
```

### Verify — Don't Just Trust `Running`
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
# both 1/1 Running, 0 restarts on the NEW pods

# Actually resolve a Service name from a pod
kubectl exec -n frontend frontend-client -- \
  curl -s -o /dev/null -w "HTTP:%{http_code}\n" --max-time 5 \
  http://backend-api.backend.svc.cluster.local
# HTTP:200
```

### Bonus Cross-Check
Worth re-testing your Task 02 NetworkPolicy after a DNS outage/recovery like this — a full CoreDNS restart is exactly the kind of cluster event that could theoretically reset network state. Confirmed `other-client` still times out reaching `backend-api`, so the NetworkPolicy from Task 02 survived the DNS incident untouched.

### Exam Tips
- `kubectl logs deploy/<name>` beats `kubectl describe pod` for crash-looping pods — the actual parse error is only in the container's stdout, not in Kubernetes events.
- A ConfigMap edit is not self-executing for a pod that's already crash-looping — know when a workload needs `rollout restart` vs. when the `reload` plugin would have handled it for you.
- If DNS breaks cluster-wide, check `kube-system` first (`coredns` ConfigMap and pod status) before assuming the problem is with a specific Service or NetworkPolicy.

---

## Common Mistakes — Week 03

```bash
# ❌ Wrong — ports nested inside a from[] list item
ingress:
- from:
  - podSelector: {...}
  - ports:
    - port: 80

# ✅ Correct — ports is a sibling of from
ingress:
- from:
  - podSelector: {...}
  ports:
  - port: 80

# ❌ Wrong — podSelector and namespaceSelector as separate from[] items (OR)
from:
- podSelector: {...}
- namespaceSelector: {...}

# ✅ Correct — combined in one from[] item (AND)
from:
- podSelector: {...}
  namespaceSelector: {...}

# ❌ Wrong — assuming a namespace has a `name` label
namespaceSelector:
  matchLabels:
    name: frontend

# ✅ Correct — the real built-in label
namespaceSelector:
  matchLabels:
    kubernetes.io/metadata.name: frontend

# ❌ Wrong — recreating a Service without --name silently renames it
kubectl expose deployment web --type=NodePort --port=80 --target-port=80
# creates Service "web", not "web-node"

# ✅ Correct — always pin the name the task actually asked for
kubectl expose deployment web --name=web-node --type=NodePort --port=80 --target-port=80
```
