# Onboarding a kind Kubernetes Cluster into Portainer BE

This covers connecting a local `kind` (Kubernetes-in-Docker) cluster to a Portainer BE instance running as a Docker container on the same host.

## Why this isn't completely straightforward

Two things make `kind` clusters different from typical "Add environment" flows:

1. **Network isolation** — Portainer's container and the kind cluster's container are separate Docker containers. `127.0.0.1`/`localhost` means different things inside each container's network namespace, so they can't reach each other via loopback addresses.
2. **No LoadBalancer controller** — kind clusters don't ship with a cloud-style LoadBalancer implementation (no MetalLB, no cloud provider integration). Portainer BE's kubeconfig **"Import"** feature requires one. See `04-known-issues-and-fixes/findings.md` for details — this is documented, expected behavior, not a bug, and the fix is to use the **Agent** method instead.

## Recommended method: Agent (NodePort), not Import

### Step 1 — Attach Portainer's container to the kind Docker network

```bash
docker network ls | grep kind
docker network connect kind portainer
```

Verify:
```bash
docker inspect portainer --format '{{json .NetworkSettings.Networks}}'
```
You should see both the default bridge network and `kind` listed, with Docker DNS resolving the `portainer` container name on that network.

### Step 2 — Deploy the Portainer Agent into the kind cluster

This can happen via Portainer's UI wizard (which deploys an agent automatically) or manually via manifest/Helm. In our case, attempting the kubeconfig "Import" flow (see known issues doc) auto-deployed an agent + a `LoadBalancer`-type Service:

```bash
k get po -n portainer
k get svc -n portainer
```

Expected output pattern:
```
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
portainer-agent            LoadBalancer   10.96.x.x       <pending>     9001:3XXXX/TCP
portainer-agent-headless   ClusterIP      None            <none>        <none>
```

### Step 3 — Patch the agent Service from LoadBalancer to NodePort

Since kind has no LoadBalancer controller, `EXTERNAL-IP` will stay `<pending>` forever. Patch it:

```bash
k patch svc portainer-agent -n portainer -p '{"spec": {"type": "NodePort"}}'
```

Confirm:
```bash
k get svc portainer-agent -n portainer
```
Note the NodePort assigned (e.g. `9001:31130/TCP` → NodePort is `31130`).

### Step 4 — Verify connectivity (optional but recommended)

Test that the NodePort and the cluster's API server are reachable from the same Docker network Portainer's container is on:

```bash
docker run --rm --network kind curlimages/curl -sk --max-time 5 \
  https://cka-lab-control-plane:31130 -o /dev/null -w "HTTP_CODE:%{http_code}\n"

docker run --rm --network kind curlimages/curl -sk --max-time 5 \
  https://cka-lab-control-plane:6443 -o /dev/null -w "HTTP_CODE:%{http_code}\n"
```

A `403` response on both confirms the TCP connection, TLS handshake, and DNS resolution all work — `403` is the *expected* response for an unauthenticated request to these endpoints, not a failure.

### Step 5 — Add the environment using the "Agent" tile (not Import, not Edge Agent)

In Portainer UI:
- **Environments → Add environment → Kubernetes → Agent** (the lightning-bolt icon, under "More options" — a legacy-labeled but fully supported option)
- **Environment address**: `<node-container-name>:<NodePort>` — e.g. `cka-lab-control-plane:31130`
- Name it (e.g. `cka-lab`)
- Submit

This connects directly to the already-running agent without going through the LoadBalancer-status-polling logic that Import/auto-provisioning uses, so it succeeds immediately.

## Why not Edge Agent?

Edge Agent is designed for the opposite topology: remote/firewalled environments that **cannot** be reached directly by Portainer, so the agent calls *out* to Portainer instead. It requires a Portainer API server URL and tunnel address reachable *from* the cluster — which reintroduces the same `localhost`-means-different-things-per-container problem, plus added tunnel/edge-key complexity, for no benefit when Portainer can already reach the cluster directly (as is the case for a local kind cluster on the same host).

## Result

```bash
k get ns
```
should match what's shown under the `cka-lab` environment's **Namespaces** view in Portainer BE, and the environment's Dashboard tab should show live node/namespace counts (not stuck loading).
