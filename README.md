# 📒 **ZSHRC-CONFIG**

## Cross-Platform Zsh Environment Orchestrator

Superior ZSH configuration and startup, dynamic support for multiple dynamic hosts and environments.

**Backup your current `~/.zshrc` file and leave new/current version containing only:**

```sh
source "$HOME/.zshrc-config/main.zsh";
```

**Fixing the `zsh compinit: insecure directories` error/warning message on macOS:**
<https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-390600994>

```sh
compaudit # list directories thought unsecure
sudo chown -R username TARGET_DIRECTORY
sudo chmod -R 755 TARGET_DIRECTORY
```

---

## 🐳 Docker Container Support

This configuration can be used inside Docker containers without installing the entire environment. The container automatically detects it's running in Docker and loads a lightweight, container-optimized profile.

### Quick Start

**Option 1: Using docker run**

```bash
# Build the example dev container
docker build -t zsh-dev:latest -f examples/Dockerfile.dev .

# Run with your host config mounted
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/.zshrc:/root/.zshrc:ro \
  -v $(pwd):/workspace \
  zsh-dev:latest
```

**Option 2: Using docker-compose**

```bash
# Start the dev container
docker-compose -f examples/docker-compose.yml up -d dev

# Attach to the container
docker-compose -f examples/docker-compose.yml exec dev zsh

# Stop when done
docker-compose -f examples/docker-compose.yml down
```

### How It Works

1. **Automatic Detection**: The config detects Docker via `/.dockerenv` or `$DOCKER_CONTAINER` environment variable
2. **Lightweight Profile**: Loads `_zenvs/docker-container/docker-container.zsh` with container-optimized settings
3. **Host Config Mount**: Your host `~/.zshrc-config` is mounted read-only into the container
4. **No macOS Binaries**: Skips loading macOS-specific binaries from `bin-arm64/` and `bin-x86_64/`

### What's Included in Container Profile

- ✅ Git configuration and aliases
- ✅ Common utilities and aliases
- ✅ Development tools
- ✅ History management
- ✅ FZF integration (if available)
- ❌ Hardware detection (skipped)
- ❌ NVM auto-load (skipped for speed)
- ❌ macOS-specific features

### Example Dockerfiles

See `examples/` directory for:

- `Dockerfile.dev` - Basic Ubuntu-based dev container
- `Dockerfile.node` - Node.js development container
- `docker-compose.yml` - Multi-container setup

### Customizing Container Behavior

Edit `_zenvs/docker-container/docker-container.zsh` to:

- Add/remove sourced libraries
- Customize aliases
- Enable/disable features (NVM, FZF, etc.)
- Adjust the container banner

---

## Antidote setup

```sh
# 1. Clone Antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# 2. Add to .zshrc
echo 'source ${ZDOTDIR:-~}/.antidote/antidote.zsh' >> ${ZDOTDIR:-~}/.zshrc

# 3. Create initial plugins file
touch ${ZDOTDIR:-~}/.zsh_plugins.txt

# 4. Add plugin load command to .zshrc
echo 'antidote load ${ZDOTDIR:-~}/.zsh_plugins.txt' >> ${ZDOTDIR:-~}/.zshrc


# THEN..
# 1. Set up preferred plugins in .zsh_plugins.txt
# 2. Configure how to integrate .zsh-config
# 3. Consider static loading for better performance
# 4. Explore plugin update strategies

```

## Profiling

**basic:**

```sh
# Before static loading
time zsh -i -c exit

# After static loading
time zsh -i -c exit
```

**detailed (saved in `.zshrc`):**

```sh
# Add this to the very top:
zmodload zsh/zprof

# And this at the very bottom:
zprof
```

## `hyperfine` - for MORE profiling

```sh
# Install hyperfine
brew install hyperfine

# Then test
hyperfine 'zsh -i -c exit'
```

---

_Submitted by_ **Justin Rankin**
[justin.blair.rankin@gmail.com](justin.blair.rankin@gmail.com)
