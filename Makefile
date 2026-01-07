SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

# Positional-arg interface (simple, docker-compose-like):
#   make <cmd> <stack> [-- <args...>]
#
# Examples:
#   make ls
#   make net services
#   make up portainer
#   make logs portainer -- -f --tail 200
#   make dc portainer -- up -d
CMD  := $(firstword $(MAKECMDGOALS))
REST := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Prevent make from trying to build the extra words as targets.
$(eval $(REST):;@:)

STACK := $(firstword $(REST))
EXTRA := $(wordlist 2,$(words $(REST)),$(REST))

.PHONY: help ls list stacks net network init up down restart pull update ps logs config validate dc compose

help:
	@echo "KLab homelab helpers"
	@echo ""
	@echo "Usage:"
	@echo "  make <cmd> <stack> [-- <args...>]"
	@echo ""
	@echo "Commands:"
	@echo "  make ls                   		# list stacks"
	@echo "  make net services         		# create shared services network (once)"
	@echo "  make init <stack>         		# create stacks/<stack>/.env from .env.example (if missing)"
	@echo "  make up <stack>           		# docker compose up -d"
	@echo "  make down <stack>         		# docker compose down"
	@echo "  make restart <stack>      		# docker compose restart"
	@echo "  make pull <stack>         		# docker compose pull"
	@echo "  make update <stack>       		# pull + up -d --remove-orphans"
	@echo "  make ps <stack>           		# docker compose ps"
	@echo "  make logs <stack> [-- ...]		# docker compose logs"
	@echo "  make config <stack> [-- ...]	# docker compose config"
	@echo "  make validate              	# validate all stacks (docker compose config)"
	@echo "  make dc <stack> -- <...>   	# raw docker compose passthrough"
	@echo ""
	@echo "Examples:"
	@echo "  make ls"
	@echo "  make net services"
	@echo "  make up portainer"
	@echo "  make logs portainer -- -f --tail 200"

ls list stacks:
	@bash scripts/stack.sh list || exit 1

net network:
	@test -n "$(STACK)" || (echo "usage: make net services" >&2; exit 2)
	@bash scripts/stack.sh network "$(STACK)" $(EXTRA) || exit 1

init:
	@test -n "$(STACK)" || (echo "usage: make init <stack>" >&2; exit 2)
	@bash scripts/stack.sh init "$(STACK)"

up:
	@test -n "$(STACK)" || (echo "usage: make up <stack>" >&2; exit 2)
	@bash scripts/stack.sh up "$(STACK)" $(EXTRA)

down:
	@test -n "$(STACK)" || (echo "usage: make down <stack>" >&2; exit 2)
	@bash scripts/stack.sh down "$(STACK)" $(EXTRA)

restart:
	@test -n "$(STACK)" || (echo "usage: make restart <stack>" >&2; exit 2)
	@bash scripts/stack.sh restart "$(STACK)" $(EXTRA)

pull:
	@test -n "$(STACK)" || (echo "usage: make pull <stack>" >&2; exit 2)
	@bash scripts/stack.sh pull "$(STACK)" $(EXTRA)

update:
	@test -n "$(STACK)" || (echo "usage: make update <stack>" >&2; exit 2)
	@bash scripts/stack.sh update "$(STACK)" $(EXTRA)

ps:
	@test -n "$(STACK)" || (echo "usage: make ps <stack>" >&2; exit 2)
	@bash scripts/stack.sh ps "$(STACK)" $(EXTRA)

logs:
	@test -n "$(STACK)" || (echo "usage: make logs <stack> [-- <args...>]" >&2; exit 2)
	@bash scripts/stack.sh logs "$(STACK)" $(EXTRA)

config:
	@test -n "$(STACK)" || (echo "usage: make config <stack> [-- <args...>]" >&2; exit 2)
	@bash scripts/stack.sh config "$(STACK)" $(EXTRA)

validate:
	@bash scripts/stack.sh validate || exit 1

dc compose:
	@test -n "$(STACK)" || (echo "usage: make dc <stack> -- <docker compose args...>" >&2; exit 2)
	@bash scripts/stack.sh dc "$(STACK)" $(EXTRA)
