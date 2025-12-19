# Docker Quick Reference

## 🚀 Fastest Ways to Get Started

### 1. Helper Script (Easiest)

```bash
./examples/run-docker-zsh.sh
```

### 2. One-Liner

```bash
docker run -it --rm -v ~/.zshrc-config:/root/.zshrc-config:ro -v $(pwd):/workspace -e DOCKER_CONTAINER=1 ubuntu:22.04 bash -c "apt-get update && apt-get install -y zsh && exec zsh"
```

### 3. Pre-Built Image

```bash
# Build once
docker build -t zsh-dev -f examples/Dockerfile.dev .

# Run anytime
docker run -it --rm -v ~/.zshrc-config:/root/.zshrc-config:ro -v $(pwd):/workspace zsh-dev
```

### 4. Docker Compose

```bash
docker-compose -f examples/docker-compose.yml run --rm dev
```

---

## 📋 Common Commands

### Build Images

```bash
# Basic dev image
docker build -t zsh-dev -f examples/Dockerfile.dev .

# Node.js image
docker build -t zsh-node-dev -f examples/Dockerfile.node .
```

### Run Containers

```bash
# Interactive with current directory mounted
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v $(pwd):/workspace \
  zsh-dev

# With specific workspace
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/projects/myapp:/workspace \
  zsh-dev

# With ports exposed
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v $(pwd):/workspace \
  -p 3000:3000 \
  zsh-node-dev
```

### Docker Compose

```bash
# Start in background
docker-compose -f examples/docker-compose.yml up -d dev

# Attach to running
docker-compose -f examples/docker-compose.yml exec dev zsh

# Run and attach (new container each time)
docker-compose -f examples/docker-compose.yml run --rm dev

# Stop all
docker-compose -f examples/docker-compose.yml down

# Rebuild
docker-compose -f examples/docker-compose.yml build

# View logs
docker-compose -f examples/docker-compose.yml logs -f dev
```

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Stop a container
docker stop <container-id>

# Remove a container
docker rm <container-id>

# Attach to running container
docker exec -it <container-id> zsh

# View container logs
docker logs <container-id>

# Inspect container
docker inspect <container-id>
```

---

## 🔧 Customization

### Enable NVM

Edit `_zenvs/docker-container/docker-container.zsh`:

```bash
# Remove this line:
export SKIP_NVM_AUTOLOAD=1

# Or add:
source "$ZSHRC_ROOT/lib/nvm.zsh"
```

### Disable Banner

```bash
# Comment out in docker-container.zsh:
# source "$ZSHRC_ROOT/_zenvs/docker-container/docker-container.banner.zsh"
```

### Add Custom Aliases

```bash
# Add to docker-container.zsh:
alias ll='ls -alh'
alias gs='git status'
```

---

## 🐛 Troubleshooting

### Container doesn't load config

```bash
# Check mount
docker run -it --rm -v ~/.zshrc-config:/root/.zshrc-config:ro ubuntu:22.04 ls -la /root/.zshrc-config

# Verify environment
docker run -it --rm -e DOCKER_CONTAINER=1 -v ~/.zshrc-config:/root/.zshrc-config:ro ubuntu:22.04 env | grep DOCKER
```

### Zsh not found

```bash
# Install in Dockerfile or run command
RUN apt-get update && apt-get install -y zsh
```

### Slow startup

```bash
# Pre-build image with zsh
# Disable heavy features in docker-container.zsh
```

---

## 📚 More Info

- Full guide: `DOCKER.md`
- Examples: `examples/` directory
- Container profile: `_zenvs/docker-container/`

---

## 💡 Tips

1. Always use `:ro` (read-only) when mounting config
2. Pre-build images for faster startup
3. Use Docker Compose for multi-container setups
4. Mount only what you need to minimize overhead
5. Keep container profile minimal for better performance
