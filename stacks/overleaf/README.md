# Overleaf Community Edition

Overleaf Community Edition is a self-hosted web app for collaborative LaTeX editing.

This stack runs:

- **Overleaf** (`sharelatex/sharelatex`)
- **MongoDB** (`mongo`) as a single-node replica set
- **Redis** (`redis`) for caching/queueing

## Deploy

This stack joins the external `services` network for upstream access (e.g. via `zoraxy` / `cloudflared`):

```bash
make net services
```

Initialize env (creates `stacks/overleaf/.env` from `.env.example` if missing):

```bash
make init overleaf
# Edit stacks/overleaf/.env with your values (set OVERLEAF_SITE_URL)
```

Then deploy:

```bash
make up overleaf
```

## Access

By default this stack **does not publish** any host ports.

- **Intra-docker URL** (from another container on the `services` network): `http://overleaf:80`
- **Recommended external access**: expose through your gateway/tunnel stack (e.g. `zoraxy`, `cloudflared`)

## Configuration

Key env vars (see `stacks/overleaf/.env.example` for the full list):

- **`OVERLEAF_SITE_URL`** (required): the external URL users will access
- **`OVERLEAF_TAG`**: pin the Overleaf image tag for reproducible upgrades
- **`OVERLEAF_MONGO_URL`**: update if you customize Mongo host/db/replica set
- **`OVERLEAF_BEHIND_PROXY`**, **`OVERLEAF_SECURE_COOKIE`**, **`OVERLEAF_TRUSTED_PROXY_IPS`**: required when terminating TLS upstream
- **`OVERLEAF_EMAIL_CONFIRMATION_DISABLED`**: set to `false` to re-enable email confirmations

## One-time setup

### MongoDB replica set

The stack includes a one-shot `overleaf-mongo-init` service that runs `rs.initiate(...)`
the first time MongoDB starts. If you ever need to re-run it manually:

```bash
make dc overleaf -- up overleaf-mongo-init
```

### Create the first admin user

Run the user creation script inside the Overleaf container:

```bash
make dc overleaf -- exec overleaf sh -lc \
  "cd /overleaf/services/web && node modules/server-ce-scripts/scripts/create-user --admin --email=you@example.com"
```

The script prints a password-setup URL. Open it, set the password, and log in.

## Networking

- **`services`**: external shared network (so gateways/tunnels can reach the UI)
- **`overleaf`**: internal stack network (created by this stack)

## Persistence

- **`overleaf-data`**: Overleaf projects and assets (`/var/lib/overleaf`)
- **`overleaf-mongo`**: MongoDB data (`/data/db`)
- **`overleaf-redis`**: Redis data (`/data`)

## Security notes

- Overleaf Community Edition does **not** sandbox compiles. Do not expose it directly to the internet.
- Always run it behind a gateway/tunnel with auth (e.g. `authentik` + `zoraxy`).
- When running behind HTTPS, set the proxy-related env vars and update `OVERLEAF_SITE_URL`.

## Upgrades

1. Update `OVERLEAF_TAG` in `stacks/overleaf/.env`.
2. Redeploy:

```bash
make update overleaf
```

Check Overleaf's MongoDB compatibility guidance before major upgrades.
# Example Stack

This stack runs:

- **Example Service** (`traefik/whoami:latest`)

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/example/.env.example` to `stacks/example/.env` (gitignored) and customize as needed:

```bash
cp stacks/example/.env.example stacks/example/.env
# Edit stacks/example/.env with your values
```

Then deploy:

```bash
make up example

# Or deploy via Portainer UI:
# - Stacks -> Add stack
# - Name: example
# - Web editor: paste stacks/example/docker-compose.yml
```

## Access

- **UI**: `http://<host>:8080`

## Notes

- **Env**: most values are configurable via environment variables (with safe defaults in `docker-compose.yml`). See `stacks/example/.env.example` for the full list.
- **Networking**:
  - `services` network is shared for inter-stack traffic (external; must exist)
- **Ports**: this stack publishes port `8080` on the host for the UI
- **Security**: review and configure security settings as needed for your deployment

## Upgrade

Bump `EXAMPLE_TAG` in `stacks/example/.env` and redeploy:

```bash
make update example
```
