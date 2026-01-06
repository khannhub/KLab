# SillyTavern

This stack runs:

- **SillyTavern** (`ghcr.io/sillytavern/sillytavern:<tag>`)

It is designed to be exposed **via the existing `cloudflared` stack** (Cloudflare Tunnel), not by publishing ports to the host.

## Deploy

Create the shared `services` network once:

```bash
make net services
```

Initialize env:

```bash
make init sillytavern
```

Edit `stacks/sillytavern/.env` (gitignored). At minimum, review:

- `SILLYTAVERN_ENABLEUSERACCOUNTS` / `SILLYTAVERN_ENABLEDISCREETLOGIN` (multi-user mode)
- `SILLYTAVERN_HOSTWHITELIST_*` (recommended for internet exposure; JSON array)
- `SILLYTAVERN_BASICAUTH*` (optional extra gate; **change defaults before enabling**)

Then deploy:

```bash
make up sillytavern
```

## Expose via Cloudflare Tunnel (recommended)

1. Deploy the `cloudflared` stack (see `stacks/cloudflared/README.md`).
2. In Cloudflare Zero Trust, configure your tunnel **Public Hostname** to point at SillyTavern over the Docker network:

- **Service type**: `HTTP`
- **URL**: `http://sillytavern:8000`

3. (Recommended) Create a **Cloudflare Access** policy for this hostname (this is your “internet user management” layer: IdP login, MFA, allowlists, etc.).

## User management (SillyTavern)

This stack enables SillyTavern **multi-user mode** by default (`enableUserAccounts`), which provides per-user data directories and accounts with roles (Admin/User).

From the docs:

- Users have a unique **handle** (lowercase letters, numbers, dashes).
- Users can self-manage via the **Account** button under **User Settings** in the top menu bar.

## Notes

- **Ports**: this stack publishes a **local-only** port binding on `127.0.0.1` (see `SILLYTAVERN_HOST_PORT`) for admin/bootstrap and development. For remote access, prefer a gateway/tunnel stack (e.g. `cloudflared`) over the `services` network.
- **Security**: runs with `no-new-privileges:true` and `cap_drop: [ALL]`.
- **Persistence**:
  - `sillytavern-config` → `/home/node/app/config`
  - `sillytavern-data` → `/home/node/app/data`
  - `sillytavern-plugins` → `/home/node/app/plugins`
  - `sillytavern-extensions` → `/home/node/app/public/scripts/extensions/third-party`

## Troubleshooting

### Container keeps restarting / cannot connect on localhost

If `make ps sillytavern` shows `Restarting (1)` and logs include:

- `A friendly reminder that the following users are not password protected:`
- `If you are not using basic authentication or whitelisting, you should set a password for all admin users.`

That is SillyTavern's **security self-check**: in the docker image it always starts with `--listen`, and it will `exit(1)` when it detects an insecure configuration.

This stack keeps **whitelist mode enabled by default**. If you turned it off, you must do at least one of:

- Enable whitelist mode (`SILLYTAVERN_WHITELISTMODE=true`)
- Enable basic auth (and change default credentials first)
- Set passwords for all admin users (via the UI or `recover.js`)
- As a last resort on trusted networks only: `SILLYTAVERN_SECURITYOVERRIDE=true`

## References

- Docker install: `https://docs.sillytavern.app/installation/docker/`
- Configuration / env vars: `https://docs.sillytavern.app/administration/config-yaml/`
- Multi-user mode: `https://docs.sillytavern.app/administration/multi-user/`
