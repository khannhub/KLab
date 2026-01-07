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
