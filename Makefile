# Gartic backend + frontend helper targets.

COMPOSE ?= docker compose

.PHONY: help up up-d down rebuild build logs ps restart

help:
	@echo "make up        Build images from the latest source and run (foreground)"
	@echo "make up-d      Same as 'make up' but detached (-d)"
	@echo "make build     Build images from the latest source (no run)"
	@echo "make rebuild   Build with --no-cache (ignore all cache) then run detached"
	@echo "make down      Stop and remove containers"
	@echo "make logs      Follow logs"
	@echo "make ps        Show container status"
	@echo "make restart   Restart running containers"

up:
	$(COMPOSE) up --build

up-d:
	$(COMPOSE) up --build -d

build:
	$(COMPOSE) build

rebuild:
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f --tail=100

ps:
	$(COMPOSE) ps

restart:
	$(COMPOSE) restart
