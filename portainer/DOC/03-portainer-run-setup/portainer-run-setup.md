# Deploying Portainer Run

[Portainer Run](https://github.com/portainer/portainer-run) is a Cloud Run-style developer-facing UI built on top of the Portainer API. It is explicitly described by the maintainers as a proof-of-concept (built for an internal project called IPOP), not a core, battle-tested Portainer product. At the time of this writeup the GitHub repo had 0 stars/forks/watchers — treat it as low-maturity tooling, suitable for lab/test use, not for production credentials or clusters without further vetting.

## What it does (per its own README)
- Presents a service-centric view across Kubernetes environments connected to Portainer
- Deploy / Services / Logs / Revisions / Edit tabs per workload
- An optional AI Assistant (requires `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`) for log triage and chat-driven operations
- Only shows workloads it deployed itself (tagged `managed-by=portainer-run`) — existing cluster workloads deployed via `kubectl` or Portainer's own UI will not appear

## Prerequisites
- A running Portainer instance (BE or CE) reachable from wherever Portainer Run's container will run
- A Portainer **personal access token** (Portainer UI → **Account → Access Tokens → Add access token**) — copy it immediately, it's shown once

## Step 1 — Clone and build

```bash
git clone https://github.com/portainer/portainer-run.git
cd portainer-run
DOCKER_BUILDKIT=0 docker build -t portainer-run .
```

## Step 2 — Networking decision

Portainer Run's container needs to reach the Portainer server. If Portainer is running as a separate container on the same host, `localhost` inside Portainer Run's container does **not** refer to the host — it refers to itself. Two working approaches:

### Option A — `--network host` (simplest on Linux)
```bash
docker run -d \
  --network host \
  -e PORTAINER_URL=https://localhost:9443 \
  -e PORT=8443 \
  -e HTTP_PORT=8080 \
  -e ENCRYPTION_KEY=<64-character-hex-string> \
  --name portainer-run \
  --restart=always \
  portainer-run
```
With host networking, `localhost` truly is the host, so `PORTAINER_URL=https://localhost:9443` resolves correctly. Note that `-p` port-publish flags are ignored under `--network host` — the container binds directly to the host's ports as set via `PORT`/`HTTP_PORT`.

### Option B — Shared custom Docker network, addressed by container name
```bash
docker run -d \
  -p 8443:443 \
  -p 8080:80 \
  -e PORTAINER_URL=https://portainer:9443 \
  -e ENCRYPTION_KEY=<64-character-hex-string> \
  --name portainer-run \
  --network <shared-network-name> \
  portainer-run
```

## Step 3 — Required environment variable not listed in the README at time of testing: `ENCRYPTION_KEY`

Running the container without it produces a **crash loop** (`Restarting (1)`) with this error repeating in the logs:
```
❌  ENCRYPTION_KEY is not set or is too short (minimum 32 characters).
    Git target credentials cannot be stored without it.
    Generate one with: openssl rand -hex 32
```

Generate one and pass it in:
```bash
openssl rand -hex 32
```
Add it as `-e ENCRYPTION_KEY=<generated-value>` to the `docker run` command (see Step 2 examples above).

**Treat this value as a secret.** It's used to encrypt stored credentials (e.g. Git target credentials). Don't paste it into chat tools, tickets, or shared docs if this becomes more than a throwaway test instance — generate a fresh one for any real deployment.

## Step 4 — Verify it started cleanly

```bash
docker ps --filter name=portainer-run
docker logs portainer-run --tail 30
```

Expect to see `Up` (not `Restarting`) and a clean startup block like:
```
✅  Portainer-Run started
    UI:        https://localhost:8443
    Portainer: https://localhost:9443
    AI triage: ✗ not set (set ANTHROPIC_API_KEY or OPENAI_API_KEY)
    TLS:       self-signed (portainer-run.crt)
```

## Step 5 — Log in

1. Open `https://localhost:8443` (or whatever `PORT` you configured).
2. Accept the self-signed certificate warning.
3. Log in using the Portainer personal access token generated earlier.

Token scope matters: a namespace-scoped token will require manually entering a namespace on deploy; a cluster-scoped token enumerates namespaces automatically.

## Optional: enabling the AI Assistant

Add `-e ANTHROPIC_API_KEY=sk-ant-...` to the `docker run` command. Without it, the Assistant button simply doesn't appear in the UI — all other functionality (Dashboard, Deploy, Services, Logs, Revisions, Edit) works normally.

## Deploying a test workload

From the **Deploy** tab:
- Name: e.g. `test-nginx`
- Image: `nginx:alpine`
- Environment: select your connected Kubernetes environment (e.g. `cka-lab`)
- Namespace: existing namespace, or new (depends on token scope)
- Exposure: NodePort is the simplest choice for non-cloud clusters like kind (see known-issues doc on LoadBalancer limitations)

After deploying, the workload should appear under **Services** within a few seconds with a "Running" status.
