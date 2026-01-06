# Authentik

This stack runs:

- **authentik server** (`authentik/server:<tag>`) for the web UI + API
- **authentik worker** (`authentik/server:<tag>`) for background tasks
- **PostgreSQL** (`postgres:alpine`) as the database
- **Redis** (`redis:alpine`) as the cache/message broker
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`) for Docker integration (optional, but enabled)

## Deploy

This stack joins external networks named `services` and `portainer`:

- `services` must be created once:

```bash
make net services
```

- `portainer` is created when you deploy the Portainer stack (recommended first).

Copy `stacks/authentik/.env.example` to `stacks/authentik/.env` (gitignored) and set at least:

```bash
POSTGRES_PASSWORD=replace-me
AUTHENTIK_SECRET_KEY=replace-me
```

Then deploy:

```bash
make up authentik

# Or deploy via Portainer UI:
# - Stacks -> Add stack
# - Name: authentik
# - Web editor: paste stacks/authentik/docker-compose.yml
```

## Access

- **UI**: this stack does **not** publish ports on the host.
  - If you use the `zoraxy` stack, add a route to `authentik-server:9000` on the `services` network.
  - For local bootstrap/testing, temporarily publish `9000:9000` on `authentik-server` (see comments in `docker-compose.yml`).

## Notes

- **Networking**:
  - `authentik` network is **internal** (stack-internal traffic only)
  - `services` network is **external** and shared for inter-stack traffic (must exist)
  - `portainer` network is shared with Portainer (external; created by the Portainer stack)
- **Volumes**:
  - `authentik-postgresql` stores the database at `/var/lib/postgresql/data`
  - `authentik-redis` stores Redis data at `/data`
  - `authentik-media` stores uploaded files at `/media`
  - `authentik-templates` stores custom templates at `/templates`
  - `authentik-blueprints` stores blueprints at `/blueprints`
- **Env**:
  - `POSTGRES_PASSWORD` and `AUTHENTIK_SECRET_KEY` are required (see `.env.example` for guidance)
  - Optional email settings are supported via `AUTHENTIK_EMAIL__*`

## Upgrade

Bump `AUTHENTIK_TAG` in `stacks/authentik/.env` and redeploy the stack in Portainer.
