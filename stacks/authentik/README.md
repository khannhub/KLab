# Authentik

This stack runs:

- **authentik server** (`authentik/server:<tag>`) for the web UI + API
- **authentik worker** (`authentik/server:<tag>`) for background tasks
- **PostgreSQL** (`postgres:alpine`) as the database
- **Redis** (`redis:alpine`) as the cache/message broker
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`) for Docker integration (optional, but enabled)

## Deploy

This stack joins external networks named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/authentik/.env.example` to `stacks/authentik/.env` (gitignored) and set at least:

```bash
make init authentik
# Edit stacks/authentik/.env and set:
# - POSTGRES_PASSWORD (strong password)
# - AUTHENTIK_SECRET_KEY (generate with: python -c "import secrets; print(secrets.token_urlsafe(64))")
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

- **Env**: most values are configurable via environment variables (with safe defaults in `docker-compose.yml`). See `stacks/authentik/.env.example` for the full list.
  - `POSTGRES_PASSWORD` and `AUTHENTIK_SECRET_KEY` are required (see `.env.example` for guidance)
  - Optional email settings are supported via `AUTHENTIK_EMAIL__*`
- **Networking**:
  - `authentik` network is **internal** (stack-internal traffic only)
  - `services` network is **external** and shared for inter-stack traffic (must exist)
- **Volumes**:
  - `authentik-postgresql` stores the database at `/var/lib/postgresql/data`
  - `authentik-redis` stores Redis data at `/data`
  - `authentik-media` stores uploaded files at `/media`
  - `authentik-templates` stores custom templates at `/templates`
  - `authentik-blueprints` stores blueprints at `/blueprints`
- **Security**: uses docker-socket-proxy with read-only socket access for enhanced security

## Upgrade

Bump `AUTHENTIK_TAG` in `stacks/authentik/.env` and redeploy:

```bash
make update authentik
```
