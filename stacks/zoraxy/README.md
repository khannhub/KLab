# Zoraxy

This stack runs:

- **Zoraxy** (`zoraxydocker/zoraxy:latest`)
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`)

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/zoraxy/.env.example` to `stacks/zoraxy/.env` (gitignored) and customize as needed:

```bash
make init zoraxy
# Edit stacks/zoraxy/.env with your values
```

Then deploy:

```bash
make up zoraxy

# Or deploy via Portainer UI:
# - Stacks -> Add stack
# - Name: zoraxy
# - Web editor: paste stacks/zoraxy/docker-compose.yml
```

## Access

- **UI**: `http://<host>:8000`
- **Proxy**: Exposed only on the `services` network (not published to host). Access via gateway/tunnel (e.g., `cloudflared` stack).

## Notes

- **Env**: most values are configurable via environment variables (with safe defaults in `docker-compose.yml`). See `stacks/zoraxy/.env.example` for the full list.
- **Networking**:
  - `zoraxy` network is **internal** (only stack-internal traffic)
  - `services` network is shared for upstream services exposed to Zoraxy (external; must exist)
- **Volumes**:
  - `zoraxy-config` stores config at `/opt/zoraxy/config`
  - `zoraxy-plugins` stores plugins at `/opt/zoraxy/plugin`
- **Security**: uses docker-socket-proxy with read-only socket access for enhanced security

## Upgrade

Bump `ZORAXY_TAG` in `stacks/zoraxy/.env` and redeploy:

```bash
make update zoraxy
```
