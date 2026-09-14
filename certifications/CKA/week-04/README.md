# Week 04 — Storage & RBAC

**CKA Domain:** Storage (10%) / Cluster Architecture, Installation & Configuration (25%)
**Week:** 04 · **Score so far:** 4/4 (100%)
**Status:** In Progress — RBAC task pending
**Date:** 2026-09-15

---

## Tasks Completed

| Task | Topic | Score |
|------|-------|-------|
| task-01-storage | PVC + Pod persistence (dynamic provisioning) | 4/4 |
| task-02-rbac | ServiceAccount + Role + RoleBinding (scoped access) | pending |

---

## Task 01 — Storage: PVC + Persistence

### Objective
Create a PVC using dynamic provisioning, mount it into a Pod, and prove the storage actually persists across Pod deletion/recreation — not just that the objects exist.

### Cluster Storage Setup
```bash
kubectl get storageclass
# NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION
# standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false
```

### Key Concept — `WaitForFirstConsumer`
A PVC against this StorageClass will sit in `Pending` until a Pod that actually references it gets scheduled — this is **expected behavior**, not a bug:
```bash
kubectl describe pvc data-claim -n storage-lab
# Events:
#   Normal  WaitForFirstConsumer  waiting for first consumer to be created before binding
```
Don't go chasing a StorageClass misconfiguration here — apply the Pod, and the PVC binds once the scheduler places it.

### Final Manifests

`pvc.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-claim
  namespace: storage-lab
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: "standard"
```

`data-claim-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  namespace: storage-lab
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: /data
        name: data-claim
  volumes:
    - name: data-claim
      persistentVolumeClaim:
        claimName: data-claim
```

### Verify — Binding
```bash
kubectl apply -f pvc.yaml            # PVC: Pending (WaitForFirstConsumer)
kubectl apply -f data-claim-pod.yaml  # Pod schedules → PVC binds
kubectl get pvc -n storage-lab       # STATUS: Bound
kubectl get pv                       # auto-created PV, matching capacity/access mode
```

### Verify — Actual Persistence, Not Just Object State
```bash
kubectl exec -it mypod -n storage-lab -- sh
# cd /data && touch test1 test2 && ls

kubectl delete -f data-claim-pod.yaml
kubectl get pvc -n storage-lab       # still Bound — deleting the Pod does NOT delete the PVC/PV

kubectl apply -f data-claim-pod.yaml
kubectl exec -it mypod -n storage-lab -- sh
# cd /data && ls
# test1  test2   ← survived Pod deletion/recreation
```

### Common Mistakes Made This Task
```bash
# ❌ Wrong — YAML indentation: volumes must be a sibling of containers, not nested deeper
spec:
  containers:
    - name: myfrontend
      ...
   volumes:        # 3 spaces instead of 2 — breaks parsing
    - name: data-claim

# ✅ Correct — same indentation level as containers
spec:
  containers:
    - name: myfrontend
      ...
  volumes:
    - name: data-claim

# ❌ Wrong — manually authoring a PersistentVolume when the StorageClass
#            already does dynamic provisioning defeats the point of it,
#            and mixes PV-only fields (capacity) with PVC-only fields (resources.requests)
kind: PersistentVolume
spec:
  resources:
    requests:
      storage: 1Gi
  volumeName: data-claim-pv   # references a PV that doesn't exist

# ✅ Correct — just request a PVC; the provisioner creates the PV for you
kind: PersistentVolumeClaim
spec:
  resources:
    requests:
      storage: 1Gi
  storageClassName: "standard"
```

### Exam Tips
- Check `kubectl get storageclass` first — if a default exists, you almost never need to hand-write a `PersistentVolume` yourself; just write the PVC.
- A `Pending` PVC isn't automatically a bug — `kubectl describe pvc` tells you *why* it's pending (check the `Events` section) before you start "fixing" things that aren't broken.
- Deleting a Pod never deletes its PVC/PV — that's the entire point of persistent storage. Only deleting the PVC itself (and depending on `reclaimPolicy`, the PV) actually removes the data.

---

## Task 02 — RBAC (Pending)

Parked mid-session — will document once solved. Given-state already provisioned: namespace `rbac-lab` with a running Pod `sample-pod` (label `app=sample`), ready to pick back up.

Objective: create a ServiceAccount + Role + RoleBinding scoped to `get`/`list`/`watch` on `pods` within `rbac-lab` only, verified via `kubectl auth can-i --as=system:serviceaccount:rbac-lab:pod-reader-sa`.
