# Cloudflared

This stack runs:

- **cloudflared** (`cloudflare/cloudflared:latest`) to run a Cloudflare Tunnel

## Deploy

This stack joins an external network named `services`. Create it once:

```bash
make net services
```

Copy `stacks/cloudflared/.env.example` to `stacks/cloudflared/.env` (gitignored) and set your tunnel token:

```bash
TUNNEL_TOKEN=<your token>
```

Then deploy:

```bash
make up cloudflared

# Or deploy via Portainer UI:
# - Stacks -> Add stack
# - Name: cloudflared
# - Web editor: paste stacks/cloudflared/docker-compose.yml
```

## Access

- **UI**: none (manage the tunnel via the Cloudflare dashboard)
- **Logs**: view in Portainer (container logs)

## Notes

- **Env**: `TUNNEL_TOKEN` is required (see `stacks/cloudflared/.env.example`).
- **Networking**:
  - `services` network is shared for upstream services the tunnel should reach (external; must exist)
- **Ports**: this stack does not publish any ports on the host.
- **Metrics/healthcheck**: metrics are bound to `127.0.0.1:2000` _inside the container_ and used for the healthcheck; they are not exposed to the host/network.
- **Security**: runs with a read-only filesystem, tmpfs for `/tmp` + `/run`, and `cap_drop: [ALL]`.
