# dockenv

A simple, Makefile-driven Docker development environment manager.

**This repo manages your dev containers, not your code.** Your actual project code lives elsewhere and is volume-mounted into the container. Each project folder here only contains environment configuration (`docker-compose.yml` + `.env`).

## Why?

- Keep dev environments isolated and reproducible
- Don't pollute your host machine with language runtimes and tools
- Spin up/down environments with simple commands
- Share consistent Dockerfiles across projects

## Features

- **Shared Dockerfiles** - Common base images in one place, no duplication
- **Minimal per-project config** - Just `docker-compose.yml` + `.env`
- **Auto-discovery** - Projects are detected automatically
- **Version managers included** - nvm, gvm, uv for flexible language versions
- **Simple commands** - `make up`, `make down`, `make shell`

## Quick Start

```bash
# Clone the template
gh repo create my-dockenv --template GareArc/dockenv --clone
cd my-dockenv

# Create a new dev environment
make init PROJECT=myapp BASE=node-go

# Edit myapp/docker-compose.yml to mount your project code:
#   volumes:
#     - /path/to/your/actual/project:/app

# Start the container
make up PROJECT=myapp

# Shell into it and start developing
make shell PROJECT=myapp

# Stop when done
make down PROJECT=myapp
```

## Available Base Images

| Base | Description |
|------|-------------|
| `node-go` | Ubuntu 24.04 + nvm (Node.js) + gvm (Go) + Claude Code |
| `python-uv` | Ubuntu 24.04 + uv (Python) + nvm (for Claude Code) |

All images include [Claude Code](https://claude.com/claude-code) CLI pre-installed.

Add your own by creating `dockerfiles/<name>.Dockerfile`.

## Commands

```bash
make help                         # Show all commands
make init PROJECT=<name> BASE=<x> # Create new project
make up PROJECT=<name>            # Start a project
make down PROJECT=<name>          # Stop a project
make shell PROJECT=<name>         # Shell into container
make logs PROJECT=<name>          # View logs
make build PROJECT=<name>         # Rebuild container
make up-all                       # Start all projects
make down-all                     # Stop all projects
make ps                           # Show running containers
make list                         # List projects
make bases                        # List available base images
make clean                        # Prune Docker system
```

## Project Structure

```
dockenv/                     # This repo - manages environments
├── Makefile                 # All the automation
├── dockerfiles/             # Shared base images
│   ├── node-go.Dockerfile
│   └── python-uv.Dockerfile
├── myapp/                   # Environment config only
│   ├── docker-compose.yml   # Mounts your actual code via volume
│   └── .env
└── another-project/
    ├── docker-compose.yml
    └── .env

~/code/myapp/                # Your actual project (elsewhere)
├── src/
├── package.json
└── ...
```

The project folders in this repo only contain Docker environment config. Your actual source code stays in its own location and is mounted into `/app` in the container.

## Customization

### Adding a new base image

Create `dockerfiles/mybase.Dockerfile`:

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y your-tools
WORKDIR /app
CMD ["/bin/bash"]
```

Then use it:

```bash
make init PROJECT=myproject BASE=mybase
```

### Custom docker-compose options

Edit your project's `docker-compose.yml` directly. Common additions:

```yaml
services:
  app:
    # ... existing config ...
    ports:
      - "${APP_PORT:-8080}:8080"
      - "5432:5432"  # Add more ports
    environment:
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      - POSTGRES_PASSWORD=dev
```

## Tips

- Use `.env` for project-specific variables (ports, env vars)
- The `/app` directory is mounted from your project folder
- Containers have `stdin_open` and `tty` enabled for interactive use
- Version managers (nvm, gvm, uv) let you switch versions inside the container
- Run `claude` inside the container to use Claude Code (requires `ANTHROPIC_API_KEY` in .env)

## License

MIT
