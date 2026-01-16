# Docker Stacks

Stacks live in subfolders:

- `stacks/<stack>/docker-compose.yml`
- Optional: `stacks/<stack>/.env` (local only; **gitignored**)
- Optional: `stacks/<stack>/.env.example` (**committed**)
- Optional: `stacks/<stack>/README.md` (**committed**)

## Using the helper commands

Use the `Makefile` for a simple, docker-compose-like interface:

```bash
make ls
make net services
make init <stack>
make up <stack>
make update <stack>
make down <stack>
make logs <stack> -- -f --tail 200
make validate
```

Under the hood, `make` wraps `scripts/stack.sh`:

```bash
bash scripts/stack.sh list
bash scripts/stack.sh network services
bash scripts/stack.sh up <stack>
bash scripts/stack.sh update <stack>
bash scripts/stack.sh validate
```

## Current stacks

- **portainer**: management UI + socket-proxy (`stacks/portainer`)
- **zoraxy**: reverse proxy + gateway (`stacks/zoraxy`)
- **cloudflared**: Cloudflare Tunnel (`stacks/cloudflared`)
- **authentik**: IdP / SSO (`stacks/authentik`)
- **openwebui**: OpenWebUI (`stacks/openwebui`)
- **librechat**: LibreChat (`stacks/librechat`)
- **lobechat**: LobeChat (server database version) (`stacks/lobechat`)
- **sillytavern**: SillyTavern (`stacks/sillytavern`)
- **postgres**: Postgres database (`stacks/postgres`)
- **mysql**: MySQL database (`stacks/mysql`)
- **mongodb**: MongoDB database (`stacks/mongodb`)
- **whodb**: WhoDB database manager UI (`stacks/whodb`)

## Creating a new stack

Copy the template:

```bash
cp -R stacks/_template stacks/<new-stack>
```

Then edit:

- `stacks/<new-stack>/docker-compose.yml`
- `stacks/<new-stack>/.env.example`
- `stacks/<new-stack>/README.md`

## Networks

### Shared network (must exist)

- `services`: shared bridge for inter-stack traffic (**must be created once** before deploying stacks that reference it)
  - **Subnet**: `172.10.0.0/24`
  - **Gateway**: `172.10.0.1`

### Core stack networks (created by stacks)

- `portainer`: internal network created by the Portainer stack
  - **Subnet**: `172.1.0.0/24`
  - **Gateway**: `172.1.0.1`
- `zoraxy`: internal network created by the Zoraxy stack
  - **Subnet**: `172.2.0.0/24`
  - **Gateway**: `172.2.0.1`
- `authentik`: internal network created by the Authentik stack
  - **Subnet**: `172.3.0.0/24`
  - **Gateway**: `172.3.0.1`
- `openwebui`: internal network created by the OpenWebUI stack
  - **Subnet**: `172.100.0.0/24`
  - **Gateway**: `172.100.0.1`
- `librechat`: internal network created by the LibreChat stack
  - **Subnet**: `172.101.0.0/24`
  - **Gateway**: `172.101.0.1`
- `lobechat`: internal network created by the LobeChat stack
  - **Subnet**: `172.102.0.0/24`
  - **Gateway**: `172.102.0.1`
