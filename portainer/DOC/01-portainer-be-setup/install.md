# Portainer BE — Installation via Docker

## Prerequisites
- Docker installed and running
- A Portainer BE license key (free 3-node license available, or purchased license)

## Step 1 — Create the data volume

```bash
docker volume create portainer_data
```

## Step 2 — Run the Portainer BE container

```bash
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ee:lts
```

Notes:
- BE uses the `portainer/portainer-ee` image, **not** `portainer/portainer-ce` (CE).
- Port `9443` serves the HTTPS UI with a self-signed certificate by default.
- Port `8000` is only needed for Edge Agent tunnel features.

## Step 3 — Verify the container started

```bash
docker ps
docker volume ls
```

You should see the `portainer` container `Up`, with `portainer_data` listed among volumes.

## Step 4 — Initial setup

1. Open `https://localhost:9443` in a browser.
2. Accept the self-signed certificate warning.
3. Create the admin username/password on the first-run screen. **Do this promptly** — the setup window times out after a few minutes of inactivity.
4. Enter the BE license key when prompted (or later under **Settings → License**).

## Verifying the running version

From container logs:
```bash
docker logs portainer 2>&1 | grep -i "version="
```

Via the API (no auth required):
```bash
curl -sk https://localhost:9443/api/status/version
```

Confirmed running version during this setup: **2.39.3**, build 28.

## Common issue: "license has invalid prefix"

If you see this in `docker logs portainer`:
```
[msg: license has invalid prefix]
```
This means the pasted license key string is malformed — usually from a copy-paste error (extra whitespace, truncated string, or wrong key format). Re-copy the key carefully (select the full string with no leading/trailing whitespace) and re-enter it under **Settings → License**.
