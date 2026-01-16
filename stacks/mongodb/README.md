# MongoDB

## What it is

This stack runs:

- **MongoDB** (`mongo:7.0`) as a standalone document database

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/mongodb/.env.example` to `stacks/mongodb/.env` (gitignored) and set a strong root password:

```bash
make init mongodb
# Edit stacks/mongodb/.env and set MONGODB_ROOT_PASSWORD
```

Then deploy:

```bash
make up mongodb
```

## Access

- **Host ports**: none (not published)
- **Intra-docker**: `mongodb:27017` on the `services` network

## Configuration

- **Required**: `MONGODB_ROOT_PASSWORD`
- **Common**: `MONGODB_ROOT_USERNAME`, `MONGODB_DATABASE`, `MONGODB_TAG`
- See `stacks/mongodb/.env.example` for the full list

## Networking

- `services` network is shared for inter-stack traffic (external; must exist)
- This stack does not expose ports on the host

## Persistence

- `mongodb-data` (named volume) stores `/data/db`

## Security notes

- Treat this database as internal-only; expose it through trusted applications or a private tunnel.
- Use least-privileged database users for apps that connect.

## Upgrades

Bump `MONGODB_TAG` in `stacks/mongodb/.env` and redeploy:

```bash
make update mongodb
```

Major upgrades may require a backup + migration; review the MongoDB release notes before bumping major versions.
