# 💻 zshrc-config

**Modular Zsh configuration that adapts to your environment.** One config, multiple hosts—macOS, Linux, Docker, VSCode, Android—with environment-specific aliases, paths, and tools.

---

## Philosophy

Provide a single, maintainable Zsh setup that:

- Detects environment (home-macos, office-macos, apnaes, docker, vscode) and loads the right profile
- Keeps `~/.zshrc` minimal—everything else lives in this repo
- Optimizes startup (VSCode/Docker use lighter profiles)
- Supports multi-system sync (commit/push from any machine)

---

## Quick Setup

**1. Minimal `~/.zshrc`**

```zsh
export ZSHRC_ROOT="$HOME/.zshrc-config"
source "$ZSHRC_ROOT/bootstrap/index.zsh"
source "$ZSHRC_ROOT/main.zsh"
```

**2. Install dependencies (fresh Mac)**

```zsh
zsh ~/.zshrc-config/scripts/install-zshrc-config-dependencies.zsh
```

Installs: Homebrew, Antidote, Powerlevel10k, Meslo Nerd Font, fzf.

**3. Environment file**

Create `.env` with `IS_HOME`, `IS_OFFICE`, `IS_SERVER` as needed so the correct `_zenvs/` profile loads.

---

## Structure

```
~/.zshrc-config/
├── bootstrap/          # Early init: profiling, Antidote, plugins, compinit, p10k
├── core/               # env, options, history, keybindings, locale
├── vendor/             # pnpm, nvm
├── lib/                # colors, utils, dev, git, widgets
├── _zenvs/             # Environment-specific (home-macos, office-macos, docker, vscode, …)
├── themes/             # p10k config
├── plugins/            # Antidote plugin list
├── scripts/            # install-zshrc-config-dependencies, vscode-clean, etc.
├── packages/
│   └── node/           # TypeScript utilities (spinner, build-path, detect-env)
├── tools/
│   ├── bin-arm64/      # Architecture-specific binaries (fastfetch, neofetch)
│   └── bin-x86_64/
└── extras/
    ├── music/          # DJ sync utilities
    ├── hardware/       # Linux hardware config
    └── examples/       # Docker examples
```

---

## Features

| Feature                   | Description                                                           |
| ------------------------- | --------------------------------------------------------------------- |
| **Environment detection** | `.env` + IP/hostname → load `_zenvs/home-macos`, `office-macos`, etc. |
| **Bootstrap**             | Antidote, plugins, compinit, p10k—correct load order                  |
| **VSCode/Docker**         | Early exit with minimal config for fast IDE terminals                 |
| **Splash**                | Time Machine, launch agents, ports, fastfetch/neofetch                |
| **Node/TS**               | Spinner, PATH deduplication, env detection (tsdown)                   |

---

## Scripts

| Script                                          | Purpose                                                              |
| ----------------------------------------------- | -------------------------------------------------------------------- |
| `scripts/install-zshrc-config-dependencies.zsh` | Install Homebrew, Antidote, p10k, fzf, Meslo font                    |
| `scripts/vscode-clean.zsh`                      | Clear VSCode / Insiders / Cursor caches (Cursor: safe only)          |
| `zupdate`                                       | Commit and push with `fetch` + `pull --rebase` for multi-system sync |

Run `zupdate` from anywhere (symlink in `~/bin`) to sync changes.

---

## Docker

Mount the config into a container—it auto-detects Docker and loads `_zenvs/docker-dev/`:

```bash
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/.zshrc:/root/.zshrc:ro \
  -v $(pwd):/workspace \
  zsh-dev:latest
```

See `extras/examples/` for Dockerfiles and docker-compose.

---

## Troubleshooting

**`zsh compinit: insecure directories`**

```zsh
compaudit                    # list insecure dirs
sudo chown -R $USER /path    # fix ownership
```

**Profiling startup**

```zsh
# Add at top of .zshrc: zmodload zsh/zprof
# Add at bottom: zprof
time zsh -i -c exit          # quick measure
```

---

_By Justin Rankin_
