# Zoraxy

This stack runs:

- **Zoraxy** (`zoraxydocker/zoraxy:latest`)
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`)

## Deploy

This stack joins the external `services` network:

- `services` must be created once:

```bash
make net services
```

Then deploy:

```bash
make up zoraxy

# Or deploy via Portainer UI:
# - Stacks -> Add stack
# - Name: zoraxy
# - Web editor: paste stacks/zoraxy/docker-compose.yaml
```

## Access

- **UI**: `http://<host>:8000`
- **Proxy**: Exposed only on the `services` network (not published to host). Access via gateway/tunnel (e.g., `cloudflared` stack).

## Notes

- **Env**: most values are configurable via environment variables (with safe defaults in `docker-compose.yaml`). See `stacks/zoraxy/.env.example` for the full list.
- **Networking**:
  - `zoraxy` network is **internal** (only stack-internal traffic)
  - `services` network is shared for upstream services exposed to Zoraxy (external; must exist)
- **Volumes**:
  - `zoraxy-config` stores config at `/opt/zoraxy/config`
  - `zoraxy-plugins` stores plugins at `/opt/zoraxy/plugin`
