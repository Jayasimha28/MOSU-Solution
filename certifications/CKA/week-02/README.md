# Week 02 — Workloads & Scheduling

**CKA Domains:** Workloads & Scheduling (15%)  
**Week:** 02 · **Score:** 21.5/24 (89%)  
**Date:** 2026-06-15

---

## Tasks Completed

| Task | Topic | Score |
|------|-------|-------|
| task-01-daemonset | DaemonSet — log collector | 3.5/4 |
| task-02-jobs | Job + CronJob — batch workloads | 7/8 |
| task-03-taints | Taints & Tolerations | 3.5/4 |
| task-04-affinity | Node Affinity | 4/4 |
| task-05-rollout | Deployment rollout + jsonpath | 3.5/4 |

---

## Task 01 — DaemonSet

### Key Concept
DaemonSet ensures one pod runs on every node. Cannot be created imperatively — generate from Deployment and modify.

### Workflow
```bash
k create deployment log-collector --image=fluentd:latest -n monitoring $do > log-collector-ds.yaml
vim log-collector-ds.yaml
```

### Changes Required After Generation
```yaml
# Change
kind: Deployment → kind: DaemonSet

# Remove these fields entirely
replicas: 1
strategy: {}
resources: {}
status: {}
```

### Final Manifest
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  namespace: monitoring
  labels:
    app: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - image: fluentd:latest
        name: fluentd
```

### Verify
```bash
k get ds -n monitoring
k get po -n monitoring -o jsonpath='{.items[0].spec.nodeName}{"\n"}'
```

### Exam Tips
- Always use `-n <namespace>` explicitly — never rely on `kubens`
- `kubens` is a plugin — may not be available on exam terminal

---

## Task 02 — Job & CronJob

### Critical Rule — $do Position
```bash
# Correct — $do BEFORE the -- separator
k create job db-backup --image=busybox -n batch $do -- sh -c "echo 'backup done' && sleep 5"

# Wrong — $do after -- gets passed to container as argument, not to kubectl
k create job db-backup --image=busybox -n batch -- sh -c "..." $do
```

### Job Manifest
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-backup
  namespace: batch
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - command:
        - sh
        - -c
        - echo 'backup done' && sleep 5
        image: busybox
        name: db-backup
      restartPolicy: Never
```

### CronJob Manifest
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup
  namespace: batch
spec:
  schedule: '*/5 * * * *'
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    metadata:
      name: cleanup
    spec:
      template:
        spec:
          containers:
          - command:
            - sh
            - -c
            - echo 'cleanup running'
            image: busybox
            name: cleanup
          restartPolicy: OnFailure
```

### Three Levels of spec — Don't Mix Them
```yaml
spec:                          # CronJob spec — history limits, schedule go here
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:                      # Job spec — completions, parallelism go here
      template:
        spec:                  # Pod spec — containers go here
          containers: ...
```

### restartPolicy
| Policy | Behaviour | Use case |
|--------|-----------|----------|
| `Never` | New pod created on each failure | Job — keep failure history visible |
| `OnFailure` | Container restarted in same pod | CronJob — clean retry |

### Cron Quick Reference
```
*/5 * * * *   every 5 minutes   ← 5 fields only, never 6
0 * * * *     every hour
0 0 * * *     every day at midnight
0 0 * * 0     every Sunday
```

### Verify Parallelism Worked
```bash
k get po -n batch
# Same AGE on two pods = ran in parallel
# db-backup-q5w4b   Completed   18s  ← parallel
# db-backup-tzlgr   Completed   18s  ← parallel
# db-backup-lwwgr   Completed    9s  ← ran after one completed
```

---

## Task 03 — Taints & Tolerations

### Taint Commands
```bash
# Add
k taint node <node> key=value:Effect

# Remove — minus sign at end
k taint node <node> key=value:Effect-

# Verify
k describe node <node> | grep -A3 Taints
```

### Taint Effects
| Effect | New Pods | Running Pods |
|--------|----------|--------------|
| `NoSchedule` | Blocked without toleration | Not evicted |
| `PreferNoSchedule` | Avoided but not blocked | Not evicted |
| `NoExecute` | Blocked without toleration | Evicted immediately |

`NoExecute` only — supports `tolerationSeconds` to delay eviction:
```yaml
tolerations:
  - key: env
    operator: "Equal"
    value: "production"
    effect: "NoExecute"
    tolerationSeconds: 3600
```

### Toleration Manifest
```yaml
spec:
  tolerations:
    - key: env
      operator: "Equal"      # Equal = match key+value | Exists = match key only
      value: "production"
      effect: "NoSchedule"
```

### Diagnostic — Pod Stuck in Pending
```bash
k describe po <pod> | grep -A5 Events
# Warning FailedScheduling: 0/1 nodes available: 1 node(s) had untolerated taint(s)
# Fix: add toleration block to pod spec
```

---

## Task 04 — Node Affinity

### Label Commands
```bash
k label node <node> disktype=ssd     # add label
k label node <node> disktype-        # remove label (minus sign)
k get node <node> --show-labels      # verify
```

### Affinity Types
| Type | Scheduling Behaviour | If Label Removed Later |
|------|---------------------|----------------------|
| `requiredDuringSchedulingIgnoredDuringExecution` | Must match — won't schedule if no match | Pod keeps running |
| `preferredDuringSchedulingIgnoredDuringExecution` | Tries to match — schedules elsewhere if no match | Pod keeps running |

### Affinity Manifest
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - image: nginx
    name: ssd-pod
```

### Taints vs Affinity — When to Use Which
| Mechanism | Direction | Applied On | Use Case |
|-----------|-----------|-----------|----------|
| Taint | Repels pods from node | Node | Dedicate node, repel most workloads |
| Affinity | Attracts pod to node | Pod | Target specific nodes for a workload |

Combined pattern for fully dedicated nodes:
```
1. Taint node        → repels everything
2. Toleration on pod → allows it on the node
3. Affinity on pod   → pins it to that node
```

---

## Task 05 — Deployment Rollout & jsonpath

### Rollout Commands
```bash
# Update image — container name, not deployment name
k set image deploy/<name> <container-name>=<new-image> -n <ns>

# Check rollout status — run BEFORE rollback
k rollout status deploy/<name> -n <ns>

# Rollback to previous version
k rollout undo deploy/<name> -n <ns>

# Rollback to specific revision
k rollout undo deploy/<name> --to-revision=2 -n <ns>

# View revision history
k rollout history deploy/<name> -n <ns>

# Scale
k scale deploy/<name> --replicas=5 -n <ns>
```

### Correct Task Order — Critical
```bash
k set image ...         # 1. update image
k rollout status ...    # 2. verify rollout complete
k rollout undo ...      # 3. then rollback
```

### Verify Rollback Worked
```bash
k describe deploy <name> -n <ns> | grep Image
```

### jsonpath — Image Extraction
```bash
# Single pod
k get po <name> -n <ns> -o jsonpath='{.spec.containers[0].image}{"\n"}'

# All pods in namespace
k get po -n <ns> -o jsonpath='{.items[*].spec.containers[0].image}{"\n"}'
```

---

## Common Mistakes — Week 02

```bash
# ❌ Wrong taint syntax
k taint node <node> env:production:NoSchedule

# ✅ Correct — = between key and value
k taint node <node> env=production:NoSchedule

# ❌ Wrong — 6-field cron
schedule: "*/5 * * * * *"

# ✅ Correct — 5 fields only
schedule: "*/5 * * * *"

# ❌ Wrong — missing operator in toleration
tolerations:
  - key: env
    value: "production"
    effect: "NoSchedule"

# ✅ Correct
tolerations:
  - key: env
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"

# ❌ Wrong — $do after --
k create job ... -- sh -c "cmd" $do

# ✅ Correct — $do before --
k create job ... $do -- sh -c "cmd"
```

---

## jsonpath Cheatsheet

```bash
# Pod IP
k get po <name> -n <ns> -o jsonpath='{.status.podIP}{"\n"}'

# Node a pod is running on
k get po <name> -n <ns> -o jsonpath='{.spec.nodeName}{"\n"}'

# Image of first container
k get po <name> -n <ns> -o jsonpath='{.spec.containers[0].image}{"\n"}'

# All pod IPs in namespace
k get po -n <ns> -o jsonpath='{.items[*].status.podIP}{"\n"}'

# Image across all pods in namespace
k get po -n <ns> -o jsonpath='{.items[*].spec.containers[0].image}{"\n"}'

# Service ClusterIP
k get svc <name> -n <ns> -o jsonpath='{.spec.clusterIP}{"\n"}'

# Node address
k get node <name> -o jsonpath='{.status.addresses[0].address}{"\n"}'
```

---