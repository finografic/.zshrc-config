# Docker Container Integration Guide

## Overview

This zshrc-config can be seamlessly used inside Docker containers without duplicating the installation. The container automatically detects it's running in Docker and loads an optimized, lightweight configuration.

---

## Quick Start

### Method 1: One-Line Docker Run

```bash
# Run Ubuntu container with your zsh config
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/.zshrc:/root/.zshrc:ro \
  -v $(pwd):/workspace \
  -e DOCKER_CONTAINER=1 \
  ubuntu:22.04 bash -c "apt-get update && apt-get install -y zsh && exec zsh"
```

### Method 2: Helper Script (Recommended)

```bash
# Make script executable (one-time)
chmod +x examples/run-docker-zsh.sh

# Run with defaults (ubuntu:22.04, current directory)
./examples/run-docker-zsh.sh

# Run with custom image and workspace
./examples/run-docker-zsh.sh node:20 ~/my-project
```

### Method 3: Pre-Built Image

```bash
# Build the dev image
docker build -t zsh-dev:latest -f examples/Dockerfile.dev .

# Run it
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/.zshrc:/root/.zshrc:ro \
  -v $(pwd):/workspace \
  zsh-dev:latest
```

### Method 4: Docker Compose

```bash
# Start development container
docker-compose -f examples/docker-compose.yml up -d dev

# Attach to running container
docker-compose -f examples/docker-compose.yml exec dev zsh

# Or start and attach in one command
docker-compose -f examples/docker-compose.yml run --rm dev

# Stop all containers
docker-compose -f examples/docker-compose.yml down
```

---

## How It Works

### Automatic Detection

The config detects Docker environments through multiple signals:

1. Presence of `/.dockerenv` file (standard Docker marker)
2. `DOCKER_CONTAINER=1` environment variable
3. `IN_DOCKER=1` environment variable

When detected, it automatically loads the container-optimized profile.

### Container Profile Location

```
_zenvs/docker-dev/
├── docker-dev.zsh          # Main container config
└── docker-dev.banner.zsh   # Container welcome banner
```

### What Gets Loaded

**Included in container profile:**

- ✅ Core utilities (`lib/utils.zsh`, `lib/common.zsh`)
- ✅ Git configuration and all git helpers
- ✅ Development tools (`lib/dev.zsh`)
- ✅ Common aliases
- ✅ History management
- ✅ FZF integration (if installed)
- ✅ Color support

**Skipped for performance:**

- ❌ Hardware detection
- ❌ macOS-specific binaries (`bin-arm64/`, `bin-x86_64/`)
- ❌ NVM auto-loading (can be enabled manually)
- ❌ macOS system integrations
- ❌ Resource-intensive features

---

## Volume Mounting Options

### Read-Only Config (Recommended)

```bash
-v ~/.zshrc-config:/root/.zshrc-config:ro
```

**Pros:**

- Prevents accidental modifications from inside container
- Safe for multiple concurrent containers
- Host config remains pristine

**Cons:**

- Can't modify config from inside container

### Read-Write Config

```bash
-v ~/.zshrc-config:/root/.zshrc-config:rw
```

**Use when:**

- Testing config changes in isolation
- Developing new features
- Need to modify config from container

### Custom Mount Location

```bash
-v ~/.zshrc-config:/host-config:ro
-e ZSHRC_ROOT=/host-config
```

Mount at any path by setting `ZSHRC_ROOT` environment variable.

---

## Customizing Container Behavior

### Enable NVM in Containers

Edit `_zenvs/docker-dev/docker-dev.zsh`:

```bash
# Remove or comment out this line:
# export SKIP_NVM_AUTOLOAD=1

# Or add NVM loading:
source "$ZSHRC_ROOT/lib/nvm.zsh" 2>/dev/null || true
```

### Disable Container Banner

```bash
# Comment out this line in docker-dev.zsh:
# source "$ZSHRC_ROOT/_zenvs/docker-dev/docker-dev.banner.zsh"
```

### Add Custom Container Aliases

Edit `_zenvs/docker-dev/docker-dev.zsh`:

```bash
# Add after existing aliases
alias myalias='echo "Custom container command"'
alias proj='cd /workspace/my-project'
```

### Change Container Prompt

```bash
# Edit the prompt section in docker-dev.zsh
PROMPT='%F{blue}🐳%f %F{cyan}%~%f %# '
```

---

## Example Dockerfiles

### Basic Dev Container

See `examples/Dockerfile.dev`:

- Ubuntu 22.04 base
- Zsh pre-installed
- Essential dev tools
- Ready for host config mount

### Node.js Dev Container

See `examples/Dockerfile.node`:

- Node.js 20 base
- Zsh + development tools
- pnpm, yarn, TypeScript pre-installed
- Optimized for JavaScript/TypeScript projects

### Creating Your Own

```dockerfile
FROM your-base-image

# Install zsh
RUN apt-get update && apt-get install -y zsh git curl && \
    chsh -s $(which zsh)

# Set environment for detection
ENV DOCKER_CONTAINER=1
ENV ZSHRC_ROOT=/root/.zshrc-config
ENV SHELL=/bin/zsh

WORKDIR /workspace
CMD ["zsh"]
```

Then run with:

```bash
docker build -t my-zsh-image .
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v $(pwd):/workspace \
  my-zsh-image
```

---

## Docker Compose Patterns

### Single Dev Container

```yaml
services:
  dev:
    image: zsh-dev:latest
    volumes:
      - ~/.zshrc-config:/root/.zshrc-config:ro
      - .:/workspace
    environment:
      - DOCKER_CONTAINER=1
    command: zsh
```

### Multiple Project Containers

```yaml
services:
  frontend:
    image: node:20
    volumes:
      - ~/.zshrc-config:/root/.zshrc-config:ro
      - ./frontend:/workspace
    working_dir: /workspace
    command: zsh

  backend:
    image: python:3.11
    volumes:
      - ~/.zshrc-config:/root/.zshrc-config:ro
      - ./backend:/workspace
    working_dir: /workspace
    command: zsh
```

### With Persistent History

```yaml
services:
  dev:
    image: zsh-dev:latest
    volumes:
      - ~/.zshrc-config:/root/.zshrc-config:ro
      - .:/workspace
      - zsh-history:/root/.zsh_history_dir
    environment:
      - DOCKER_CONTAINER=1

volumes:
  zsh-history:
    driver: local
```

---

## Troubleshooting

### Container Doesn't Detect Config

**Check:**

1. Config is mounted: `ls -la /root/.zshrc-config`
2. Environment variable is set: `echo $DOCKER_CONTAINER`
3. Detection file exists: `ls -la /.dockerenv`

**Solution:**

```bash
# Manually set the environment variable
docker run -it --rm \
  -e DOCKER_CONTAINER=1 \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  your-image
```

### Zsh Not Found

**Solution:**
Install zsh in your Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y zsh
```

Or use the helper script which auto-installs zsh.

### Host Binaries Don't Work

**Issue:**
macOS binaries in `bin-arm64/` and `bin-x86_64/` won't run in Linux containers.

**Solution:**
The container profile automatically skips these. Install Linux versions:

```bash
# Inside container
apt-get install -y exa bat fd-find fzf
```

### Slow Container Startup

**Optimize:**

1. Build image with zsh pre-installed
2. Disable heavy features in `docker-dev.zsh`:
   ```bash
   export SKIP_NVM_AUTOLOAD=1
   export SKIP_FANCY_PROMPTS=1
   ```
3. Comment out unused library sources

### Permission Issues

**Issue:**
Files created in container are owned by root.

**Solution:**
Run as specific user:

```bash
docker run -it --rm \
  -u $(id -u):$(id -g) \
  -v ~/.zshrc-config:/home/user/.zshrc-config:ro \
  -v $(pwd):/workspace \
  your-image
```

Or use Docker's user remapping feature.

---

## Performance Tips

### Pre-Build Your Image

Don't install zsh on every run:

```bash
# Build once
docker build -t my-zsh-dev -f examples/Dockerfile.dev .

# Reuse
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  my-zsh-dev
```

### Use Docker Compose for Repeated Usage

```bash
# Start once
docker-compose up -d dev

# Attach multiple times
docker-compose exec dev zsh
```

### Minimize Mounted Files

Mount only what you need:

```bash
# Instead of entire home directory
-v ~/.zshrc-config:/root/.zshrc-config:ro

# Not this
-v ~/:/host
```

### Cache Plugin Installations

Use a volume for plugin cache:

```yaml
volumes:
  - zsh-plugins:/root/.antidote
```

---

## Advanced Usage

### Multi-Stage Build for Minimal Image

```dockerfile
# Builder stage
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y zsh git curl

# Runtime stage
FROM ubuntu:22.04
COPY --from=builder /usr/bin/zsh /usr/bin/zsh
COPY --from=builder /usr/bin/git /usr/bin/git
ENV DOCKER_CONTAINER=1
CMD ["zsh"]
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Test in Container
        run: |
          docker run -it --rm \
            -v ${{ github.workspace }}:/workspace \
            -v ~/.zshrc-config:/root/.zshrc-config:ro \
            zsh-dev:latest \
            zsh -c "cd /workspace && ./run-tests.sh"
```

### SSH into Running Container

```bash
# Start container in background
docker run -d --name dev-container \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  zsh-dev:latest sleep infinity

# SSH-like access
docker exec -it dev-container zsh
```

---

## Reference

### Environment Variables

| Variable               | Purpose                      | Default               |
| ---------------------- | ---------------------------- | --------------------- |
| `DOCKER_CONTAINER`     | Trigger container detection  | `1`                   |
| `IN_DOCKER`            | Alternative detection flag   | `1`                   |
| `ZSHRC_ROOT`           | Config location in container | `/root/.zshrc-config` |
| `SKIP_NVM_AUTOLOAD`    | Skip NVM initialization      | `1`                   |
| `SKIP_HARDWARE_DETECT` | Skip hardware checks         | `1`                   |

### Key Files

| File                                           | Purpose                     |
| ---------------------------------------------- | --------------------------- |
| `main.zsh`                                     | Entry point, detects Docker |
| `_zenvs/docker-dev/docker-dev.zsh` | Container profile           |
| `examples/Dockerfile.dev`                      | Basic dev image             |
| `examples/Dockerfile.node`                     | Node.js dev image           |
| `examples/docker-compose.yml`                  | Compose configurations      |
| `examples/run-docker-zsh.sh`                   | Helper script               |

---

## Best Practices

1. **Always mount config read-only** (`:ro`) unless testing changes
2. **Pre-build images** with zsh installed for faster startup
3. **Use Docker Compose** for multi-container or repeated workflows
4. **Keep container profile minimal** - only load what you need
5. **Test locally first** before using in CI/CD
6. **Version your Dockerfiles** alongside your config
7. **Document custom configurations** in your project's README

---

## Need Help?

- Check if `/.dockerenv` exists: `ls -la /.dockerenv`
- Verify mount: `ls -la /root/.zshrc-config`
- View detection: `echo $DOCKER_CONTAINER $IN_DOCKER`
- Test manually: `source /root/.zshrc-config/main.zsh`
- Review logs: `docker logs <container-name>`

For issues, check the main project README or create an issue on the repository.
