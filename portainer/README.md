# Portainer Setup & Onboarding Documentation

Captured documentation from setting up Portainer Business Edition (BE), onboarding a Kubernetes (kind) cluster, and deploying Portainer Run as a developer-facing UI layer.

**Environment this was tested on:**
- Host: Ubuntu (ThinkPad E14 Gen 3)
- Docker installed and running
- Kubernetes cluster: `kind` (cluster name `cka-lab`)
- Portainer BE version: **2.39.3** (build 28)

## Folder structure

| Folder | Contents |
|---|---|
| `01-portainer-be-setup/` | Installing Portainer BE via Docker, license activation |
| `02-kind-cluster-onboarding/` | Connecting a local kind Kubernetes cluster to Portainer BE |
| `03-portainer-run-setup/` | Deploying Portainer Run (Cloud Run-style UI) against the Portainer BE instance |
| `04-known-issues-and-fixes/` | Findings, gotchas, and the corrected verdict on the Import/LoadBalancer issue |

## Quick summary of what was done

1. Deployed **Portainer BE** as a Docker container (`portainer/portainer-ee:lts`), activated with a license key.
2. Attempted to onboard an existing **kind** Kubernetes cluster using the BE "Import" (kubeconfig) feature — this requires a working LoadBalancer controller, which kind does not have by default. This is documented, expected behavior, not a bug.
3. Used the **Agent** connection method instead (NodePort-exposed Portainer agent), which connected successfully and does not require a LoadBalancer.
4. Deployed **Portainer Run**, an experimental Cloud Run-style developer UI that talks to the Portainer BE API, including the required `ENCRYPTION_KEY` environment variable (undocumented in the README at time of testing).
5. Successfully logged into Portainer Run via a Portainer personal access token and deployed a test workload.

See `04-known-issues-and-fixes/findings.md` for the full writeup suitable for sharing with a team.
