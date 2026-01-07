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
- **sillytavern**: SillyTavern (`stacks/sillytavern`)
- **authentik**: IdP / SSO (`stacks/authentik`)

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
  - **Subnet**: `172.21.10.0/24`
  - **Gateway**: `172.21.10.1`
- `zoraxy`: internal network created by the Zoraxy stack
  - **Subnet**: `172.21.20.0/24`
  - **Gateway**: `172.21.20.1`
- `authentik`: internal network created by the Authentik stack
  - **Subnet**: `172.21.30.0/24`
  - **Gateway**: `172.21.30.1`
