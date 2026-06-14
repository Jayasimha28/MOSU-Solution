# CKA — Certified Kubernetes Administrator

Structured 6-week hands-on preparation for the CKA exam.  
Exam format: 2 hours · live cluster · 100% hands-on · 66% to pass.

---

## Progress

| Week | Topic | Status | Score |
|------|-------|--------|-------|
| Week 1 | Cluster Architecture · kubectl · Deployments · Resources | ✅ Done | 12/14 (86%) |
| Week 2 | DaemonSets · Jobs · CronJobs · Taints · Affinity · Rollouts | ✅ Done | 21.5/24 (89%) |
| Week 3 | Services · Networking · NetworkPolicy · CoreDNS | 🔜 Next | — |
| Week 4 | Storage · RBAC | ⬜ Pending | — |
| Week 5 | ETCD · Cluster Upgrades · Troubleshooting | ⬜ Pending | — |
| Week 6 | Full Mock Exams · Exam Readiness | ⬜ Pending | — |

**Running total: 33.5/38 (88%)**

---

## Exam Domains

| Domain | Weight |
|--------|--------|
| Cluster Architecture, Installation & Configuration | 25% |
| Workloads & Scheduling | 15% |
| Services & Networking | 20% |
| Storage | 10% |
| Troubleshooting | 30% |

---

## Terminal Setup

```bash
# Aliases — set at start of every session
alias k=kubectl
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kgd='kubectl get deployments'
alias kd='kubectl describe'
export do='--dry-run=client -o yaml'
export now='--force --grace-period=0'
source <(kubectl completion bash)
complete -F __start_kubectl k
```

---

## Key Rules

- Always `k create ns <name>` before applying any manifest
- Always `$do` before `--` in job commands
- Always delete pods with `$now`
- Always use tab completion — never type pod names manually
- Always `k config current-context` at the start of every session

---

## Weekly Index

- [Week 1](./week-01/) — Cluster Architecture, kubectl, Deployments
- [Week 2](./week-02/) — Workloads, Scheduling, Taints, Affinity, Rollouts
- [Week 3](./week-03/) — Services, Networking, NetworkPolicy *(coming)*
- [Week 4](./week-04/) — Storage, RBAC *(coming)*

---

*Exam target: July 2026*