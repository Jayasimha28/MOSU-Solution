# portainer-run-test-app

A minimal static HTML/CSS/JS page used to test Portainer Run's **Vibe Deploy** feature against a Kubernetes environment (`cka-lab`, a local `kind` cluster).

No build step, no Dockerfile — Vibe Deploy detects this as a static site (no `package.json`/`requirements.txt`/etc. present) and serves it via the nginx runtime automatically.

## Files
- `index.html` — the page
- `style.css` — styling
- `script.js` — sets a timestamp on load, just to confirm static assets are served correctly

## Deployment
Deployed via Portainer Run's Vibe Deploy flow, pointed at this repository as a Git target.
