# Postgres

## What it is

This stack runs:

- **Postgres** (`postgres:16`) as a standalone relational database

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/postgres/.env.example` to `stacks/postgres/.env` (gitignored) and set a strong password:

```bash
make init postgres
# Edit stacks/postgres/.env and set POSTGRES_PASSWORD
```

Then deploy:

```bash
make up postgres
```

## Access

- **Host ports**: none (not published)
- **Intra-docker**: `postgres:5432` on the `services` network

## Configuration

- **Required**: `POSTGRES_PASSWORD`
- **Common**: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_TAG`
- See `stacks/postgres/.env.example` for the full list

## Networking

- `services` network is shared for inter-stack traffic (external; must exist)
- This stack does not expose ports on the host

## Persistence

- `postgres-data` (named volume) stores `/var/lib/postgresql/data`

## Security notes

- Treat this database as internal-only; expose it through trusted applications or a private tunnel.
- Use least-privileged database users for apps that connect.

## Upgrades

Bump `POSTGRES_TAG` in `stacks/postgres/.env` and redeploy:

```bash
make update postgres
```

Major upgrades may require a backup + migration; review the Postgres release notes before bumping major versions.
