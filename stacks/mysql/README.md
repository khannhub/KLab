# MySQL

## What it is

This stack runs:

- **MySQL** (`mysql:8.4`) as a standalone relational database

## Deploy

This stack joins an external network named `services`:

- `services` must be created once:

```bash
make net services
```

Copy `stacks/mysql/.env.example` to `stacks/mysql/.env` (gitignored) and set strong passwords:

```bash
make init mysql
# Edit stacks/mysql/.env and set MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD
```

Then deploy:

```bash
make up mysql
```

## Access

- **Host ports**: none (not published)
- **Intra-docker**: `mysql:3306` on the `services` network

## Configuration

- **Required**: `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`
- **Common**: `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_TAG`
- See `stacks/mysql/.env.example` for the full list

## Networking

- `services` network is shared for inter-stack traffic (external; must exist)
- This stack does not expose ports on the host

## Persistence

- `mysql-data` (named volume) stores `/var/lib/mysql`

## Security notes

- Treat this database as internal-only; expose it through trusted applications or a private tunnel.
- Use least-privileged database users for apps that connect.

## Upgrades

Bump `MYSQL_TAG` in `stacks/mysql/.env` and redeploy:

```bash
make update mysql
```

Major upgrades may require a backup + migration; review the MySQL release notes before bumping major versions.
