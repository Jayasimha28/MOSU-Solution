# CKA Mentor Context

## My Setup
- Name: Jay
- Repo: cka-prep-2026/
- OS: Ubuntu, ThinkPad E14
- Cluster: Kind, single node, context: kind-cka-lab, v1.35.0
- Known issue: jay user kubeconfig can go stale — fix with `kind export kubeconfig --name cka-lab`
- Always verify context with `k config current-context` before starting any session

## Aliases Set
```bash
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

## Training Plan
- 4 hrs/week, bi-weekly LinkedIn posts
- Week 1 ✅ Done — Architecture, kubectl, Deployments, Resources — 86%
- Week 2 ✅ Done — DaemonSets, Jobs, CronJobs, Taints, Affinity, Rollouts — 89%
- Week 3 🔜 Next — Services, Networking, NetworkPolicy, CoreDNS
- Week 4 ⬜ — Storage, RBAC
- Week 5 ⬜ — ETCD, Upgrades, Troubleshooting
- Week 6 ⬜ — Full Mocks

## Scores

### Week 1 — 12/14 (86%)
- Task 1: 3/3 — control plane identification
- Task 2: 3/3 — API server manifest
- Task 3: 2.5/4 — missing --force, jsonpath not used
- Task 4: 3.5/4 — namespace-first habit, duplicate stub bug

### Week 2 — 21.5/24 (89%)
- Task 1: 3.5/4 — DaemonSet — forgot explicit -n flag
- Task 2: 7/8 — Job + CronJob — $do placed after -- separator
- Task 3: 3.5/4 — Taints — pod name typo, missing operator field
- Task 4: 4/4 — Node Affinity — perfect
- Task 5: 3.5/4 — Rollout — ran rollback before checking rollout status

### Running Total: 33.5/38 (88%)

## Known Weak Areas
- ~~jsonpath not natural~~ ✅ Fixed Week 2
- Namespace-first habit — always `k create ns` before applying manifests
- `$do` must come BEFORE `--` in job commands
- Task ordering — read ALL steps before executing ANY
- Tab complete resource names — never type pod names manually
- Rollout sequence: `set image` → `rollout status` → `rollout undo`

## Mentor Instructions
Act as my CKA mentor and examiner. You know my setup above.
Pick up from where I left off. Be critical. No hand-holding.
Review answers and always show the exam-efficient approach.
Generate GitHub README and LinkedIn post at end of each session.

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

## Key Commands Cheatsheet

### DaemonSet
```bash
# No imperative create — generate from deployment and edit
k create deploy <name> --image=<img> -n <ns> $do > ds.yaml
# Change kind: Deployment → DaemonSet, remove replicas/strategy
```

### Job & CronJob
```bash
k create job <name> --image=<img> -n <ns> $do -- sh -c "cmd" > job.yaml
k create cronjob <name> --image=<img> --schedule="*/5 * * * *" -n <ns> $do -- sh -c "cmd" > cj.yaml
```

### Taints
```bash
k taint node <node> key=value:Effect        # add
k taint node <node> key=value:Effect-       # remove
k label node <node> key=value               # add label
k label node <node> key-                    # remove label
```

### Rollout
```bash
k set image deploy/<name> <container>=<image> -n <ns>
k rollout status deploy/<name> -n <ns>
k rollout undo deploy/<name> -n <ns>
k rollout history deploy/<name> -n <ns>
k scale deploy/<name> --replicas=5 -n <ns>
```