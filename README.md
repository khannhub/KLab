<div align="center">

# KLab (Homelab)

Docker Compose stacks + notes for running my homelab.

</div>

## What’s in here

- **Compose stacks** live in `stacks/<stack>/docker-compose.yml`
- **Stack docs** live next to each stack (`stacks/<stack>/README.md`)
- **Helper commands** live in the `Makefile` (wrapping `scripts/stack.sh`)

## Quickstart

List stacks:

```bash
make ls
```

Bring up a stack:

```bash
make up portainer
```

Create the shared `services` network (**once**, before deploying other stacks):

```bash
make net services
```

Pull + redeploy a stack (update images and restart containers):

```bash
make update portainer
```

Validate all stacks (parses each compose file):

```bash
make validate
```

## Conventions

- **Per-stack env**: put secrets and host-specific values in `stacks/<stack>/.env` (gitignored)
- **Document env**: commit `stacks/<stack>/.env.example`
- **Shared networking**:
  - `services`: shared bridge for inter-stack traffic (must be created once, e.g. via `make net services`)
    - **Subnet**: `172.10.0.0/24`
    - **Gateway**: `172.10.0.1`
  - Core stack networks are created by their stacks (see `stacks/README.md` for the reserved subnets)

## Stacks

- **Portainer**: `stacks/portainer` (see stack README for details)
- **Zoraxy**: `stacks/zoraxy` (reverse proxy + gateway)
- **cloudflared**: `stacks/cloudflared` (Cloudflare Tunnel)
- **SillyTavern**: `stacks/sillytavern`
- **authentik**: `stacks/authentik` (IdP / SSO)

## CI/CD

### CI (GitHub Actions)

This repo runs CI on every push/PR:

- **Workflow lint**: `actionlint`
- **YAML lint**: `yamllint`
- **Shell lint**: `shellcheck`
- **Compose validation**: `docker compose … config` for every stack

### CD / Deploy (opt-in)

There’s a manual deploy workflow: `.github/workflows/deploy.yml` (GitHub Actions → **Deploy (SSH)**).

Required repo (or environment) secrets:

- **`SSH_HOST`**: homelab host (e.g. `nas.lan`)
- **`SSH_USER`**: ssh user (e.g. `ubuntu`)
- **`SSH_PRIVATE_KEY`**: private key for the deploy user
- **`DEPLOY_PATH`**: path to this repo on the homelab host (e.g. `/opt/klab`)
- **`CF_ACCESS_CLIENT_ID`**: Cloudflare Access client ID (for SSH tunneling)
- **`CF_ACCESS_CLIENT_SECRET`**: Cloudflare Access client secret (for SSH tunneling)
- **`SSH_PORT`**: optional (defaults to `22`)

The deploy job will SSH in, `git fetch` + `git reset --hard` to the workflow’s commit SHA, then run:

```bash
make update portainer
```

### CD / Portainer GitOps webhook (opt-in)

If you manage stacks in Portainer via GitOps, this repo can notify Portainer on every push to `main` when a stack compose file changes.

Workflow: `.github/workflows/portainer-gitops-webhook.yml`

Required repo secret:

- **`PORTAINER_WEBHOOKS`**: JSON mapping stack name (`stacks/<stack>`) → Portainer webhook URL.

Example:

```json
{
  "portainer": "https://portainer.example.com/api/stacks/webhooks/<token>",
  "authentik": "https://portainer.example.com/api/stacks/webhooks/<token>",
  "cloudflared": "https://portainer.example.com/api/stacks/webhooks/<token>",
  "sillytavern": "https://portainer.example.com/api/stacks/webhooks/<token>",
  "zoraxy": "https://portainer.example.com/api/stacks/webhooks/<token>"
}
```

If `PORTAINER_WEBHOOKS` is not set, the workflow will skip.

## License

See [LICENSE](LICENSE).
