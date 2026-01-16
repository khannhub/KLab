# OpenWebUI

OpenWebUI is a self-hosted web UI for LLM chat that can connect to local models (e.g. Ollama) and OpenAI-compatible APIs.

This stack runs:

- **OpenWebUI** (`ghcr.io/open-webui/open-webui`)

## Deploy

This stack joins the external `services` network for upstream access (e.g. via `zoraxy` / `cloudflared`):

```bash
make net services
```

Initialize env (creates `stacks/openwebui/.env` from `.env.example` if missing):

```bash
make init openwebui
# Edit stacks/openwebui/.env with your values
```

Then deploy:

```bash
make up openwebui
```

## Access

By default this stack **does not publish** any host ports.

- **Intra-docker URL** (from another container on the `services` network): `http://openwebui:8080`
- **Recommended external access**: expose through your gateway/tunnel stack (e.g. `zoraxy`, `cloudflared`)

## Configuration

Key env vars (see `stacks/openwebui/.env.example` for the full list):

- **`OPENWEBUI_TAG`**: pin the image tag (recommended for production; e.g. `v0.6.42`)
- **`OPENWEBUI_SECRET_KEY`**: strongly recommended; generate with `openssl rand -base64 48`
- **`OPENWEBUI_AUTH`**: keep `true` for multi-user; setting `false` enables single-user mode and is **irreversible**
- **`OPENWEBUI_OLLAMA_BASE_URL`**: point to your Ollama instance (host or another container)

## Networking

- **`services`**: external shared network (so gateways/tunnels can reach the UI)
- **`openwebui`**: internal stack network (created by this stack)

## Persistence

- **`openwebui-data`** (named volume): stores OpenWebUI data at `/app/backend/data`

## Security notes

- Do **not** expose OpenWebUI directly to the internet. Put it behind a gateway/tunnel with auth (e.g. `authentik` + `zoraxy` or Cloudflare Access).
- Set `OPENWEBUI_SECRET_KEY` before you consider this “production”.
- Think carefully before enabling single-user mode (`OPENWEBUI_AUTH=false`) — it cannot be reverted.

## Upgrades

1. Update `OPENWEBUI_TAG` in `stacks/openwebui/.env` (pin to a release tag for reproducibility).
2. Redeploy:

```bash
make update openwebui
```
