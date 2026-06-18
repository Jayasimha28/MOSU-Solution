# Known Issues, Findings & Corrected Verdicts

This document captures investigation results from setting up Portainer BE against a `kind` cluster — written to be shareable with a team for a "is this expected or a bug" discussion.

---

## Finding 1: Kubernetes "Import" gets stuck in `WaitingForAgent` on clusters without a LoadBalancer (e.g. kind)

### Initial (incorrect) assessment
Our first read of the logs looked like a bug: Portainer's "Import" flow appeared to silently deploy its own fresh agent + LoadBalancer Service into the cluster, then loop forever:
```
failure in state | error="could not get service ip or hostname" state=WaitingForAgent
retrying | attempt=N max_attempts=30 state=WaitingForAgent
```

### Corrected verdict: this is documented, expected behavior — not a bug

Portainer's official documentation for the Import feature states this as a hard prerequisite:

> "Your cluster must have a load balancer configured and enabled."

And confirms the mechanism we observed is intentional:

> "Portainer will use the information in the kubeconfig file to connect to your environment then deploy and configure the Portainer Agent for you."

`kind` clusters have no LoadBalancer controller by default (no MetalLB, no cloud integration), so this prerequisite was never met. The endless retry loop is Portainer correctly waiting for a `status.loadBalancer.ingress` field on the Service that will never populate on this cluster type — not a defect.

Additional context confirming Import's status in Portainer's product direction:

> "Importing an existing Kubernetes environment is a legacy option that does not support edge features or policy management. For most use cases, the Edge Agent is recommended."

> "Portainer currently recommends the Edge Agent for most new Kubernetes connections; the classic Agent and kubeconfig import options are legacy workflows."

### We verified this was not a connectivity issue

Using a disposable `curl` container on the same Docker network as both Portainer and the kind cluster:
```bash
docker run --rm --network kind curlimages/curl -sk --max-time 5 \
  https://cka-lab-control-plane:31130 -o /dev/null -w "HTTP_CODE:%{http_code}\n"
docker run --rm --network kind curlimages/curl -sk --max-time 5 \
  https://cka-lab-control-plane:6443 -o /dev/null -w "HTTP_CODE:%{http_code}\n"
```
Both returned `HTTP_CODE:403` — meaning TCP connection, TLS handshake, and DNS resolution all succeeded, and the servers responded correctly to an unauthenticated request (403 is the expected response, not a failure). This confirms the network path was healthy; the issue was purely Portainer's Import flow checking for a LoadBalancer-assigned address that doesn't exist on this cluster type.

### Working alternative: the "Agent" method

Manually patching the Service to `NodePort` did not unstick the existing Import provisioning task (it kept checking the wrong field), but registering the environment fresh via the **Agent** tile — pointing directly at `<node>:<NodePort>` — connected immediately. This is a fully supported, documented connection method, not a workaround:

> "You can connect a cluster by installing the Portainer Agent and registering it in Portainer, by importing a kubeconfig file, or by using the Edge Agent for clusters that Portainer can't reach directly."

Full steps in `02-kind-cluster-onboarding/onboarding-kind-cluster.md`.

---

## Finding 2: Portainer Run requires `ENCRYPTION_KEY`, undocumented in README at time of testing

Running Portainer Run's container without an `ENCRYPTION_KEY` environment variable results in a crash loop with:
```
❌  ENCRYPTION_KEY is not set or is too short (minimum 32 characters).
    Git target credentials cannot be stored without it.
```
This variable was **not** present in the env var reference table in the project's README at the time of testing (which listed `PORTAINER_URL`, `ANTHROPIC_API_KEY`, `PORT`, `HTTP_PORT`, `SSL_CERT`, `SSL_KEY`, `SSL_CERT_DIR`, `CACHE_DIR`). Either the requirement was added after that README snapshot, or it was simply missed in docs. Worth flagging upstream if filing feedback on the project, since Portainer Run is an early-stage proof-of-concept (per its own README) and this kind of doc gap is plausible for a project at that maturity.

Fix: generate a key with `openssl rand -hex 32` and pass it via `-e ENCRYPTION_KEY=<value>`.

---

## Recommendation for on-prem, multi-cluster rollout

For environments with **no existing LoadBalancer controller** and a need for **repeatable onboarding across multiple clusters**, prefer the **Agent + NodePort** method over Import + MetalLB:

| | Agent + NodePort | Import + MetalLB |
|---|---|---|
| Extra infra per cluster | None (NodePort is built into vanilla K8s) | MetalLB install + IP range allocation per cluster |
| Repeatability | High — same manifest/Helm + NodePort pattern everywhere | Lower — MetalLB setup must be templated and maintained per cluster |
| Feature support | Fully supported (legacy-labeled, not deprecated) | Fully supported, but also legacy-labeled; no edge/policy features either way |
| Network considerations | Need a reachable node IP:port from Portainer's network | Need a routable LoadBalancer IP range available on the network |

On real on-prem hardware (unlike `kind`), node IPs are routable on the actual network, so firewall/ACL rules between Portainer's host and each cluster's nodes become a genuine consideration to confirm with whoever owns network policy — this is different from the Docker-internal addressing used in the kind lab setup.

---

## Version info for reference

- Portainer BE: **2.39.3**, build 28
- Tested against: `kind` v1.35.0 cluster (single control-plane node)
