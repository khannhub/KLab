# Portainer

This stack runs:

- **Portainer** (`portainer/portainer-ee:lts`)
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`)

## Deploy

Copy `stacks/portainer/.env.example` to `stacks/portainer/.env` (gitignored) and customize as needed:

```bash
make init portainer
# Edit stacks/portainer/.env with your values
```

Then deploy:

```bash
make up portainer

# Or deploy via Portainer UI (once it's running):
# - Stacks -> Add stack
# - Name: portainer
# - Web editor: paste stacks/portainer/docker-compose.yml
```

## Access

- **UI**: `https://<host>:9443`

## Notes

- **EE vs CE**: this compose file uses **Portainer EE** (`portainer/portainer-ee:lts`). If you want the community edition instead, swap the image to **CE** (see Portainer docs).
- **Env**: most values are configurable via environment variables (with safe defaults in `docker-compose.yml`). See `stacks/portainer/.env.example` for the full list.
  - Set `PORTAINER_ORIGINS` in `stacks/portainer/.env` for trusted origins
- **Networking**:
  - `portainer` network is created by this stack (internal; private to the stack unless other stacks explicitly join it)
  - `services` network is shared for inter-stack traffic (external; must exist if other stacks need it)
- **Volumes**:
  - `portainer` (named volume) stores Portainer data at `/data`
- **Security**: uses docker-socket-proxy with read-only socket access for enhanced security

## Upgrade

Bump `PORTAINER_TAG` in `stacks/portainer/.env` and redeploy:

```bash
make update portainer
```
