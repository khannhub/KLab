# Portainer

This stack runs:

- **Portainer** (`portainer/portainer-ee:lts`)
- **Docker socket proxy** (`ghcr.io/tecnativa/docker-socket-proxy:latest`)

## Deploy

```bash
make up portainer
```

## Access

- **UI**: `https://<host>:9443`

## Notes

- **EE vs CE**: this compose file uses **Portainer EE** (`portainer/portainer-ee:lts`). If you want the community edition instead, swap the image to **CE** (see Portainer docs).
- **Env**: set `PORTAINER_ORIGINS` in `stacks/portainer/.env` (see `.env.example`).
- **Networking**:
  - `portainer` network is created by this stack (private to the stack unless other stacks explicitly join it)
- **Volume**: `portainer` (named volume) stores Portainer data at `/data`
