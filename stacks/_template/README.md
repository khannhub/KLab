# Stack Template

Copy this folder to start a new stack:

```bash
cp -R stacks/_template stacks/<new-stack>
```

Then update:

- `docker-compose.yml` (services, ports, volumes, labels)
- `.env.example` (document required env vars)
- `README.md` (how to deploy + how to access)

## Conventions

- Put real values in `.env` (gitignored)
- Commit `.env.example` with safe defaults/examples
