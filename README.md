# dockenv

A simple, Makefile-driven Docker development environment manager. Create isolated dev containers for your projects with minimal boilerplate.

## Features

- **Shared Dockerfiles** - Common base images in one place, no duplication
- **Minimal per-project config** - Just `docker-compose.yml` + `.env`
- **Auto-discovery** - Projects are detected automatically
- **Version managers included** - nvm, gvm, uv for flexible language versions
- **Simple commands** - `make up`, `make down`, `make shell`

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/dockenv.git
cd dockenv

# Create a new project
make init PROJECT=myapp BASE=node-go

# Start the container
make up PROJECT=myapp

# Shell into it
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
dockenv/
├── Makefile                 # All the automation
├── dockerfiles/             # Shared base images
│   ├── node-go.Dockerfile
│   └── python-uv.Dockerfile
├── myapp/                   # Your project
│   ├── docker-compose.yml
│   └── .env
└── another-project/
    ├── docker-compose.yml
    └── .env
```

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
