
Here:

```markdown
# CKA Mock Exam – Practice Template

⏱ Time Limit: 60–120 Minutes  
🚫 No Google  
✅ Only kubectl + official docs  

---

## Question 1 – Pod Scheduling (10 Points)

Create a pod named nginx-test in namespace prod that:
- Runs nginx image
- Is scheduled only on nodes labeled env=prod
- Has memory limit 128Mi

---

## Question 2 – Troubleshooting (15 Points)

A pod in namespace finance is in CrashLoopBackOff state.

Tasks:
- Identify root cause
- Fix the issue
- Ensure pod is running

---

## Question 3 – Networking (15 Points)

Create a NetworkPolicy that:
- Denies all traffic to namespace secure
- Allows traffic only from namespace frontend

---

## Question 4 – Storage (10 Points)

Create:
- A PV of size 1Gi
- A PVC requesting 1Gi
- Mount into pod named app

---

## Scoring

- 80%+ → Exam Ready
- 60–79% → Revise Weak Areas
- Below 60% → Redo Core Concepts