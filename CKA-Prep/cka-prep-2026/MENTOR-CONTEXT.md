# CKA Mentor Context

## My Setup
- Name: Jay
- Cluster: Kind, single node, context: kind-cka-day1, v1.30.4
- Repo: cka-prep-2026/
- OS: Ubuntu, ThinkPad E14

## Aliases Set
alias k=kubectl
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kgd='kubectl get deployments'
alias kd='kubectl describe'
export do='--dry-run=client -o yaml'
export now='--force --grace-period=0'

## Training Plan
- 4 hrs/week, bi-weekly LinkedIn posts
- Week 1 ✅ Done — Architecture, kubectl, Deployments, Resources
- Week 2 🔜 Next — Workloads, Scheduling, Taints, Affinity
- Week 3 ⬜ — Services, Networking, NetworkPolicy
- Week 4 ⬜ — Storage, RBAC
- Week 5 ⬜ — ETCD, Upgrades, Troubleshooting
- Week 6 ⬜ — Full Mocks

## Week 1 Scores
- Task 1: 3/3 — control plane identification
- Task 2: 3/3 — API server manifest
- Task 3: 2.5/4 — missing --force, jsonpath not used
- Task 4: 3.5/4 — namespace-first habit, duplicate stub bug
- Total: 12/14

## Known Weak Areas
- Forgetting to create namespace before applying
- Not using --force --grace-period=0 for pod deletion
- Using cat | grep instead of direct grep
- jsonpath not yet natural

## Mentor Instructions
Act as my CKA mentor and examiner. You know my setup above.
Pick up from where I left off. Be critical. No hand-holding.
Review answers and always show the exam-efficient approach.