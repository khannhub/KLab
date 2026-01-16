# LibreChat

LibreChat is a self-hosted ChatGPT-like UI that can connect to multiple AI providers and supports search + RAG components.

This stack runs:

- **LibreChat** (`ghcr.io/danny-avila/librechat`)
- **MongoDB** (persistence for chats/users/config)
- **Meilisearch** (search)
- **pgvector Postgres** (vector DB used by RAG API)
- **LibreChat RAG API** (`ghcr.io/danny-avila/librechat-rag-api-dev-lite`)

## Deploy

This stack joins the external `services` network for upstream access (e.g. via `zoraxy` / `cloudflared`):

```bash
make net services
```

Initialize env (creates `stacks/librechat/.env` from `.env.example` if missing):

```bash
make init librechat
# Edit stacks/librechat/.env with your values
```

Then deploy:

```bash
make up librechat
```

## Access

By default this stack **does not publish** any host ports.

- **Intra-docker URL** (from another container on the `services` network): `http://librechat:3080`
- **Recommended external access**: expose through your gateway/tunnel stack (e.g. `zoraxy`, `cloudflared`)

## Configuration

Key env vars (see `stacks/librechat/.env.example` for the full list):

- **`CREDS_KEY` / `CREDS_IV` / `JWT_SECRET` / `JWT_REFRESH_SECRET` / `MEILI_MASTER_KEY`**: required for a production-grade deployment
  - Generate with OpenSSL (see comments in `.env.example`)
- **MongoDB auth**:
  - `LIBRECHAT_MONGO_ROOT_PASSWORD` (admin)
  - `LIBRECHAT_MONGO_PASSWORD` (LibreChat app user)
- **Reverse proxy / external URLs**:
  - `DOMAIN_CLIENT`, `DOMAIN_SERVER`, `TRUST_PROXY`

## Networking

- **`services`**: external shared network (so gateways/tunnels can reach LibreChat)
- **`librechat`**: internal stack network (MongoDB/Meilisearch/pgvector/RAG live only here)

## Persistence

Named volumes:

- **MongoDB**: `librechat-mongodb-data`
- **Meilisearch**: `librechat-meilisearch-data`
- **Vector DB**: `librechat-vectordb-data`
- **LibreChat uploads/logs/images**: `librechat-uploads`, `librechat-logs`, `librechat-images`

## Security notes

- Do **not** expose LibreChat directly to the internet. Put it behind a gateway/tunnel with auth (e.g. `authentik` + `zoraxy` or Cloudflare Access).
- Replace all `replace-me` placeholders in `stacks/librechat/.env` before treating this as production.
- MongoDB and Meilisearch are intentionally **not** on the shared `services` network to minimize blast radius.

## Upgrades

1. Bump image tags in `stacks/librechat/.env` (pin to a known-good tag for reproducibility).
2. Redeploy:

```bash
make update librechat
```
