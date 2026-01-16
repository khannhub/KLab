# LobeChat (Server Database Version)

LobeChat’s “server database” mode stores conversations/settings in Postgres (with `pgvector`) and uses an external authentication provider (NextAuth recommended for Docker).

This stack runs:

- **LobeChat server DB image** (`lobehub/lobe-chat-database`)
- **Postgres + pgvector** (`pgvector/pgvector:pg16`)

## Deploy

This stack joins the external `services` network for upstream access (e.g. via `zoraxy` / `cloudflared`):

```bash
make net services
```

Initialize env (creates `stacks/lobechat/.env` from `.env.example` if missing):

```bash
make init lobechat
# Edit stacks/lobechat/.env with your values
```

Then deploy:

```bash
make up lobechat
```

## Access

By default this stack **does not publish** any host ports.

- **Intra-docker URL** (from another container on the `services` network): `http://lobechat:3210`
- **Recommended external access**: expose through your gateway/tunnel stack (e.g. `zoraxy`, `cloudflared`)

## Configuration

### Database (Postgres + pgvector)

LobeChat server DB mode requires a Postgres instance with the `pgvector` plugin.
This stack includes a `pgvector/pgvector:pg16` container with a persistent named volume.

### Authentication (NextAuth)

In server DB mode you need an authentication provider to distinguish users.

For Docker deployments, LobeHub recommends **NextAuth** (enabled by default in the `lobe-chat-database` image).

Key env vars:

- **`NEXT_AUTH_SECRET`**: generate with `openssl rand -base64 32`
- **`NEXTAUTH_URL`**: usually `https://<your-domain>/api/auth`
- **`NEXT_AUTH_SSO_PROVIDERS`**: comma-separated providers (e.g. `authentik`)

### Authentik provider (recommended with this repo)

Since this repo already contains an `authentik` stack, Authentik is a good default SSO provider.

Docs: `https://lobehub.com/docs/self-hosting/advanced/auth/next-auth/authentik`

Required env vars (when using Authentik):

- `AUTH_AUTHENTIK_ID`
- `AUTH_AUTHENTIK_SECRET`
- `AUTH_AUTHENTIK_ISSUER`

### S3 storage (recommended)

For multimodal conversations and uploads, server DB mode uses S3-compatible object storage.

Docs:

- Server DB overview: `https://lobehub.com/docs/self-hosting/server-database`
- S3 config: `https://lobehub.com/docs/self-hosting/advanced/s3`

Set:

- `S3_ACCESS_KEY_ID`
- `S3_SECRET_ACCESS_KEY`
- `S3_ENDPOINT`
- `S3_BUCKET`
- `S3_PUBLIC_DOMAIN`

## Networking

- **`services`**: external shared network (so gateways/tunnels can reach the UI)
- **`lobechat`**: internal stack network (Postgres <-> app traffic only)

## Persistence

- **`lobechat-postgres-data`** (named volume): Postgres data directory

## Security notes

- Do **not** expose LobeChat directly to the internet. Put it behind a gateway/tunnel with auth (e.g. `authentik` + `zoraxy` or Cloudflare Access).
- Replace all `replace-me` placeholders in `stacks/lobechat/.env` before treating this as production.
- Keep Postgres internal-only (this compose does not publish DB ports).

## Upgrades

1. Bump `LOBECHAT_TAG` (and/or the Postgres tag) in `stacks/lobechat/.env`.
2. Redeploy:

```bash
make update lobechat
```
