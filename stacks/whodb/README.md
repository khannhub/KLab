# WhoDB

## What it is

This stack runs:

- **WhoDB** (`clidey/whodb:latest`) as a web-based database manager UI

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/whodb/.env.example` to `stacks/whodb/.env` (gitignored) and customize as needed:

```bash
make init whodb
# Edit stacks/whodb/.env with your values
```

Then deploy:

```bash
make up whodb
```

## Access

- **Host ports**: none (not published)
- **Intra-docker**: `http://whodb:8080` on the `services` network
- **UI**: use a gateway/tunnel stack (e.g. `zoraxy` or `cloudflared`) to expose it safely

## Configuration

- Optional AI integrations: `WHODB_OLLAMA_*`, `WHODB_OPENAI_*`, `WHODB_ANTHROPIC_*`
- See `stacks/whodb/.env.example` for the full list

## Networking

- `services` network is shared for inter-stack traffic (external; must exist)
- This stack does not expose ports on the host

## Persistence

- None by default. If you want to manage a local SQLite DB, bind-mount it and reference it in the UI.

## Security notes

- WhoDB is an admin UI; keep it behind SSO or a private tunnel and do not expose it publicly without auth.

## Upgrades

Bump `WHODB_TAG` in `stacks/whodb/.env` and redeploy:

```bash
make update whodb
```
