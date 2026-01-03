# Docker Development Environment Manager
# Usage:
#   make up PROJECT=myproject      - Start a specific project
#   make down PROJECT=myproject    - Stop a specific project
#   make up-all                    - Start all projects
#   make down-all                  - Stop all projects
#   make ps                        - Show running containers
#   make list                      - List available projects
#   make logs PROJECT=myproject    - View logs for a project
#   make shell PROJECT=myproject   - Shell into a project's container
#   make init PROJECT=myproject BASE=python  - Scaffold a new project

SHELL := /bin/bash

# Shared dockerfiles directory
DOCKERFILES_DIR := $(CURDIR)/dockerfiles

# Auto-discover available base images
BASES := $(shell ls -1 $(DOCKERFILES_DIR)/*.Dockerfile 2>/dev/null | xargs -I{} basename {} .Dockerfile)

# Auto-discover projects (directories containing docker-compose.yml or compose.yml)
PROJECTS := $(shell find . -maxdepth 2 -name 'docker-compose.yml' -o -name 'compose.yml' | xargs -I{} dirname {} | sed 's|^\./||' | grep -v dockerfiles | sort -u)

.PHONY: help list ps up down up-all down-all logs shell build clean init bases

help:
	@echo "Docker Dev Environment Manager"
	@echo ""
	@echo "Usage:"
	@echo "  make up PROJECT=<name>            Start a project"
	@echo "  make down PROJECT=<name>          Stop a project"
	@echo "  make up-all                       Start all projects"
	@echo "  make down-all                     Stop all projects"
	@echo "  make build PROJECT=<name>         Build a project"
	@echo "  make logs PROJECT=<name>          View project logs"
	@echo "  make shell PROJECT=<name>         Shell into container"
	@echo "  make ps                           Show running containers"
	@echo "  make list                         List available projects"
	@echo "  make init PROJECT=<name> BASE=<x> Create new project"
	@echo "  make bases                        List available base images"
	@echo ""
	@echo "Available projects:"
	@$(MAKE) --no-print-directory list

list:
	@if [ -z "$(PROJECTS)" ]; then \
		echo "  (no projects found)"; \
	else \
		for proj in $(PROJECTS); do \
			echo "  - $$proj"; \
		done; \
	fi

bases:
	@echo "Available base images (in dockerfiles/):"
	@for base in $(BASES); do \
		echo "  - $$base"; \
	done

# Find the compose file for a project
define get_compose_file
$(shell \
	if [ -f "$(1)/docker-compose.yml" ]; then \
		echo "$(1)/docker-compose.yml"; \
	elif [ -f "$(1)/compose.yml" ]; then \
		echo "$(1)/compose.yml"; \
	fi \
)
endef

# Find the env file for a project (optional)
define get_env_file
$(shell \
	if [ -f "$(1)/.env" ]; then \
		echo "--env-file $(1)/.env"; \
	fi \
)
endef

# Validate PROJECT is set
define check_project
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT is required. Usage: make $(1) PROJECT=<name>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ]; then \
		echo "Error: Project directory '$(PROJECT)' not found"; \
		exit 1; \
	fi
	@if [ -z "$(call get_compose_file,$(PROJECT))" ]; then \
		echo "Error: No docker-compose.yml or compose.yml found in '$(PROJECT)'"; \
		exit 1; \
	fi
endef

up:
	$(call check_project,up)
	@echo "Starting $(PROJECT)..."
	docker compose -f $(call get_compose_file,$(PROJECT)) $(call get_env_file,$(PROJECT)) -p $(PROJECT) up -d

down:
	$(call check_project,down)
	@echo "Stopping $(PROJECT)..."
	docker compose -f $(call get_compose_file,$(PROJECT)) -p $(PROJECT) down

build:
	$(call check_project,build)
	@echo "Building $(PROJECT)..."
	docker compose -f $(call get_compose_file,$(PROJECT)) $(call get_env_file,$(PROJECT)) -p $(PROJECT) build

logs:
	$(call check_project,logs)
	docker compose -f $(call get_compose_file,$(PROJECT)) -p $(PROJECT) logs -f

shell:
	$(call check_project,shell)
	@container=$$(docker compose -f $(call get_compose_file,$(PROJECT)) -p $(PROJECT) ps -q | head -1); \
	if [ -z "$$container" ]; then \
		echo "Error: No running container found for $(PROJECT)"; \
		exit 1; \
	fi; \
	docker exec -it $$container /bin/sh -c "command -v bash >/dev/null && exec bash || exec sh"

ps:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

up-all:
	@if [ -z "$(PROJECTS)" ]; then \
		echo "No projects found"; \
		exit 0; \
	fi
	@for proj in $(PROJECTS); do \
		echo "Starting $$proj..."; \
		$(MAKE) --no-print-directory up PROJECT=$$proj; \
	done

down-all:
	@if [ -z "$(PROJECTS)" ]; then \
		echo "No projects found"; \
		exit 0; \
	fi
	@for proj in $(PROJECTS); do \
		echo "Stopping $$proj..."; \
		$(MAKE) --no-print-directory down PROJECT=$$proj; \
	done

clean:
	docker system prune -f

# Initialize a new project
# Usage: make init PROJECT=myproject BASE=python
BASE ?= ubuntu

init:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT is required."; \
		echo "Usage: make init PROJECT=<name> BASE=<image>"; \
		echo ""; \
		echo "Available bases:"; \
		for base in $(BASES); do echo "  - $$base"; done; \
		exit 1; \
	fi
	@if [ -d "$(PROJECT)" ]; then \
		echo "Error: Directory '$(PROJECT)' already exists"; \
		exit 1; \
	fi
	@if [ ! -f "$(DOCKERFILES_DIR)/$(BASE).Dockerfile" ]; then \
		echo "Error: Base '$(BASE)' not found in dockerfiles/"; \
		echo ""; \
		echo "Available bases:"; \
		for base in $(BASES); do echo "  - $$base"; done; \
		exit 1; \
	fi
	@echo "Creating project: $(PROJECT) (base: $(BASE))"
	@mkdir -p $(PROJECT)
	@echo 'services:' > $(PROJECT)/docker-compose.yml
	@echo '  app:' >> $(PROJECT)/docker-compose.yml
	@echo '    build:' >> $(PROJECT)/docker-compose.yml
	@echo '      context: .' >> $(PROJECT)/docker-compose.yml
	@echo '      dockerfile: ../dockerfiles/$(BASE).Dockerfile' >> $(PROJECT)/docker-compose.yml
	@echo '    volumes:' >> $(PROJECT)/docker-compose.yml
	@echo '      - .:/app' >> $(PROJECT)/docker-compose.yml
	@echo '    ports:' >> $(PROJECT)/docker-compose.yml
	@echo '      - "$${APP_PORT:-8080}:8080"' >> $(PROJECT)/docker-compose.yml
	@echo '    environment:' >> $(PROJECT)/docker-compose.yml
	@echo '      - ANTHROPIC_API_KEY=$${ANTHROPIC_API_KEY:-}' >> $(PROJECT)/docker-compose.yml
	@echo '    stdin_open: true' >> $(PROJECT)/docker-compose.yml
	@echo '    tty: true' >> $(PROJECT)/docker-compose.yml
	@echo 'APP_PORT=8080' > $(PROJECT)/.env
	@echo '# ANTHROPIC_API_KEY=sk-ant-...' >> $(PROJECT)/.env
	@echo ""
	@echo "Created $(PROJECT)/"
	@echo "  ├── docker-compose.yml  (uses dockerfiles/$(BASE).Dockerfile)"
	@echo "  └── .env"
	@echo ""
	@echo "Next: make up PROJECT=$(PROJECT)"
