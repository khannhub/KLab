#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() {
  echo "error: $*" >&2
  exit 1
}

warn() {
  echo "warn: $*" >&2
}

detect_stacks_dir() {
  local root_dir="${1:?root dir required}"
  local new="${root_dir}/stacks"
  local legacy="${root_dir}/docker/stacks"

  local has_new=0
  local has_legacy=0
  [[ -d "${new}" ]] && has_new=1
  [[ -d "${legacy}" ]] && has_legacy=1

  if [[ "${has_new}" -eq 1 && "${has_legacy}" -eq 1 ]]; then
    warn "both '${new}' and '${legacy}' exist; using '${new}' (remove the unused tree to avoid confusion)"
    echo "${new}"
    return 0
  fi

  if [[ "${has_new}" -eq 1 ]]; then
    echo "${new}"
    return 0
  fi

  if [[ "${has_legacy}" -eq 1 ]]; then
    warn "using legacy stacks dir '${legacy}' (consider migrating to '${new}')"
    echo "${legacy}"
    return 0
  fi

  die "no stacks dir found (expected '${new}' or '${legacy}')"
}

STACKS_DIR="$(detect_stacks_dir "${ROOT_DIR}")"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/stack.sh list
  bash scripts/stack.sh network services
  bash scripts/stack.sh init <stack>
  bash scripts/stack.sh up <stack>
  bash scripts/stack.sh down <stack>
  bash scripts/stack.sh restart <stack>
  bash scripts/stack.sh pull <stack>
  bash scripts/stack.sh update <stack>
  bash scripts/stack.sh ps <stack>
  bash scripts/stack.sh logs <stack> [--follow] [--since ...] [--tail ...]
  bash scripts/stack.sh config <stack>
  bash scripts/stack.sh dc <stack> <docker compose args...>
  bash scripts/stack.sh validate

Notes:
  - Stack directories must be in stacks/<stack>/docker-compose.yml (legacy: docker/stacks/<stack>/docker-compose.yml)
  - Directories starting with '_' are ignored (e.g. _template)
  - If stacks/<stack>/.env exists, it's passed via --env-file
  - validate/config will fall back to .env.example when .env isn't present
  - up/update will create stacks/<stack>/.env from .env.example (once) and stop so you can edit it safely
  - Create the shared 'services' network once before deploying other stacks:
      bash scripts/stack.sh network services
  - services network IPAM can be overridden with:
      SERVICES_SUBNET (default: 172.10.0.0/24)
      SERVICES_GATEWAY (default: 172.10.0.1)
EOF
}

require_docker() {
  command -v docker >/dev/null 2>&1 || die "docker is not installed or not on PATH"
}

require_docker_compose() {
  require_docker
  docker compose version >/dev/null 2>&1 || die "'docker compose' is not available (install Docker Desktop / compose plugin)"
}

ensure_services_network() {
  local name="services"
  local subnet="${SERVICES_SUBNET:-172.10.0.0/24}"
  local gateway="${SERVICES_GATEWAY:-172.10.0.1}"

  if docker network inspect "${name}" >/dev/null 2>&1; then
    local existing=""
    existing="$(docker network inspect "${name}" --format '{{(index .IPAM.Config 0).Subnet}} {{(index .IPAM.Config 0).Gateway}}' 2>/dev/null || true)"
    if [[ -n "${existing}" ]]; then
      local existing_subnet existing_gateway
      existing_subnet="${existing%% *}"
      existing_gateway="${existing#* }"
      if [[ "${existing_subnet}" != "${subnet}" || "${existing_gateway}" != "${gateway}" ]]; then
        warn "network '${name}' exists but IPAM differs (have: ${existing_subnet} gw ${existing_gateway}; want: ${subnet} gw ${gateway})"
      fi
    fi
    return 0
  fi

  docker network create \
    --driver bridge \
    --subnet "${subnet}" \
    --gateway "${gateway}" \
    "${name}" >/dev/null

  echo "created network '${name}' (${subnet}, gw ${gateway})"
}

maybe_create_env_file() {
  local dir="${1:?stack dir required}"
  if [[ -f "${dir}/.env" ]]; then
    return 0
  fi
  if [[ -f "${dir}/.env.example" ]]; then
    cp "${dir}/.env.example" "${dir}/.env"
    warn "created ${dir}/.env from .env.example (edit it before deploying)"
  fi
}

ensure_env_file_for_deploy() {
  local dir="${1:?stack dir required}"
  if [[ -f "${dir}/.env" ]]; then
    return 0
  fi
  if [[ -f "${dir}/.env.example" ]]; then
    cp "${dir}/.env.example" "${dir}/.env"
    die "created ${dir}/.env from .env.example; edit it and re-run"
  fi
}

list_stacks() {
  [[ -d "${STACKS_DIR}" ]] || die "missing stacks dir: ${STACKS_DIR}"
  for dir in "${STACKS_DIR}"/*; do
    [[ -d "$dir" ]] || continue
    local name
    name="$(basename "$dir")"
    [[ "$name" == _* ]] && continue
    [[ -f "${dir}/docker-compose.yml" ]] || continue
    echo "$name"
  done | sort
}

stack_dir() {
  local stack="${1:?stack name required}"
  local dir="${STACKS_DIR}/${stack}"
  [[ -d "$dir" ]] || die "unknown stack: ${stack} (expected directory ${dir})"
  echo "$dir"
}

compose_file() {
  local dir="${1:?stack dir required}"
  local file="${dir}/docker-compose.yml"
  [[ -f "$file" ]] || die "missing compose file: ${file}"
  echo "$file"
}

pick_env_file() {
  local dir="${1:?stack dir required}"
  if [[ -f "${dir}/.env" ]]; then
    echo "${dir}/.env"
    return 0
  fi
  return 1
}

pick_env_file_for_config() {
  local dir="${1:?stack dir required}"
  if pick_env_file "$dir" >/dev/null; then
    pick_env_file "$dir"
    return 0
  fi
  if [[ -f "${dir}/.env.example" ]]; then
    echo "${dir}/.env.example"
    return 0
  fi
  return 1
}

compose_run() {
  local stack="${1:?stack name required}"
  shift
  local dir file
  dir="$(stack_dir "$stack")"
  file="$(compose_file "$dir")"

  local -a args=(
    --project-name "$stack"
    --project-directory "$dir"
    -f "$file"
  )

  local envfile=""
  if envfile="$(pick_env_file "$dir")"; then
    args+=(--env-file "$envfile")
  fi

  docker compose "${args[@]}" "$@"
}

compose_run_config() {
  local stack="${1:?stack name required}"
  shift
  local dir file
  dir="$(stack_dir "$stack")"
  file="$(compose_file "$dir")"

  local -a args=(
    --project-name "$stack"
    --project-directory "$dir"
    -f "$file"
  )

  local envfile=""
  if envfile="$(pick_env_file_for_config "$dir")"; then
    args+=(--env-file "$envfile")
  fi

  docker compose "${args[@]}" "$@"
}

cmd="${1:-}"
case "$cmd" in
  -h|--help|help|"")
    usage
    exit 0
    ;;
  list|ls)
    list_stacks
    ;;
  network|net)
    require_docker
    network="${2:-}"; [[ -n "$network" ]] || die "missing network name (supported: services)"
    shift 2 || true
    case "$network" in
      services)
        ensure_services_network
        ;;
      *)
        die "unknown network: ${network} (supported: services)"
        ;;
    esac
    ;;
  init)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    dir="$(stack_dir "$stack")"
    maybe_create_env_file "$dir"
    ;;
  up)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    dir="$(stack_dir "$stack")"
    ensure_env_file_for_deploy "$dir"
    shift 2 || true
    compose_run "$stack" up -d "$@"
    ;;
  down)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" down "$@"
    ;;
  restart)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" restart "$@"
    ;;
  pull)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" pull "$@"
    ;;
  update|deploy|redeploy)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    dir="$(stack_dir "$stack")"
    ensure_env_file_for_deploy "$dir"
    shift 2 || true
    compose_run "$stack" pull
    compose_run "$stack" up -d --remove-orphans "$@"
    ;;
  ps)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" ps "$@"
    ;;
  logs)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" logs "$@"
    ;;
  config)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    compose_run_config "$stack" config "$@"
    ;;
  dc|compose)
    require_docker_compose
    stack="${2:-}"; [[ -n "$stack" ]] || die "missing stack name"
    shift 2 || true
    [[ "$#" -gt 0 ]] || die "missing docker compose args (example: dc <stack> up -d)"
    compose_run "$stack" "$@"
    ;;
  validate)
    require_docker_compose
    failed=0
    while IFS= read -r stack; do
      echo "==> ${stack}"
      if ! compose_run_config "$stack" config >/dev/null; then
        echo "FAILED: ${stack}" >&2
        failed=1
      fi
    done < <(list_stacks)
    exit "$failed"
    ;;
  *)
    usage
    die "unknown command: ${cmd}"
    ;;
esac
