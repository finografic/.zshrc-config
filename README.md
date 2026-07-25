# 💻 zshrc-config

**Modular Zsh configuration that adapts to your environment.** One config, eight host profiles—home-macos, office-macos, home-linux, docker-dev, vscode, android, apnaes, codex—with environment-specific aliases, paths, and tools, plus AI-agent-friendly project docs.

---

## Philosophy

Provide a single, maintainable Zsh setup that:

- Detects environment (`.env` flags + hostname/IP) and loads the matching `_zenvs/` profile
- Keeps `~/.zshrc` minimal—everything else lives in this repo
- Optimizes startup (VSCode/Docker/Codex use lighter, early-exit profiles)
- Supports multi-system sync (commit/push from any machine via `zupdate`)
- Stays legible to both humans and AI coding agents (`AGENTS.md`, `.agents/`, `docs/`)

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
├── core/               # env detection, zsh options, history, keybindings, locale
├── themes/             # p10k config, prompt, theme switcher
├── lib/                # colors, utils, node/, clean/, dev, git, fzf, widgets
├── vendor/             # pnpm, nvm init/PATH
├── _zenvs/             # One profile per host:
│   ├── home-macos/     #   personal macOS
│   ├── office-macos/   #   work macOS (minimal skeleton — populate per job)
│   ├── home-linux/     #   personal Linux
│   ├── docker-dev/     #   containers (auto-detected)
│   ├── vscode/         #   VSCode integrated terminal (early exit)
│   ├── codex/          #   OpenAI Codex agent shells (early exit)
│   ├── android/        #   Termux
│   └── apnaes/         #   remote server
├── plugins/            # Antidote plugin list (.zsh_plugins.txt + generated)
├── packages/node/      # TypeScript CLI utilities (spinner, PATH build), built via tsdown
├── scripts/            # Setup, cleanup, and repo-maintenance scripts
├── tools/              # bin-arm64/ + bin-x86_64/ arch-specific binaries (fastfetch, neofetch, …)
├── extras/             # music/, hardware/, examples/ — optional, not sourced by default
├── docs/               # ROADMAP.md, process notes, todo analysis
├── .agents/            # handoff.md (tracked state) + memory.md (local session log)
├── main.zsh            # Orchestrator: core → theme → lib → _zenvs/$ZENV → splash
├── update-config.zsh   # zupdate implementation (commit + rebase + push)
└── AGENTS.md           # AI-agent entry point (linked from CLAUDE.md)
```

### Load order

`~/.zshrc` sources `bootstrap/index.zsh` (profiling → Antidote → plugins → compinit → p10k), then `main.zsh`, which detects `$ZENV` (`core/env.zsh`), early-exits for Codex/VSCode shells, loads theme + core options + shared `lib/` modules, then sources the matching `_zenvs/$ZENV/$ZENV.zsh` profile before the splash screen.

---

## Features

| Feature                   | Description                                                           |
| ------------------------- | --------------------------------------------------------------------- |
| **Environment detection** | `.env` + IP/hostname → load `_zenvs/home-macos`, `office-macos`, etc. |
| **Bootstrap**             | Antidote, plugins, compinit, p10k—correct load order                  |
| **VSCode/Docker**         | Early exit with minimal config for fast IDE terminals                 |
| **Splash**                | Time Machine, launch agents, ports, fastfetch/neofetch                |
| **Node/TS**               | Spinner + PATH deduplication (`packages/node`, built via tsdown)      |
| **Lint/format**           | `oxlint` + `oxfmt`, run via Husky `pre-commit` (`lint-staged`)        |
| **Commit hygiene**        | `commitlint` (Conventional Commits) via Husky `commit-msg`            |
| **AI-agent docs**         | `AGENTS.md` entry point, `.agents/` memory, `docs/todo/ROADMAP.md`    |

---

## Scripts

| Script                                          | Purpose                                                              |
| ----------------------------------------------- | -------------------------------------------------------------------- |
| `scripts/install-zshrc-config-dependencies.zsh` | Install Homebrew, Antidote, p10k, fzf, Meslo font                    |
| `lib/clean/clean.ides.zsh`                      | Clear VSCode / Insiders / Cursor caches (Cursor: safe only)          |
| `lib/node.zsh`                                  | Barrel for Node UX: nvm-autoload + `pn`/`pnr`/`npmls`                |
| `zupdate`                                       | Commit and push with `fetch` + `pull --rebase` for multi-system sync |
| `pnpm lint` / `pnpm lint:fix`                   | Run `oxlint` (optionally with `--fix`)                               |
| `pnpm format:check` / `pnpm format:fix`         | Run `oxfmt` in check or write mode                                   |
| `pnpm lint:md` / `pnpm lint:md:fix`             | Markdown lint via `@finografic/md-lint`                              |

Run `zupdate` from anywhere (symlink in `~/bin`) to sync changes.

---

## Alias Registry

You can keep local repo paths out of tracked shell files by defining an alias map in `.env`. Because `.env` is sourced by zsh, associative arrays work.

Example `.env` entries:

```zsh
typeset -gA REPO_ALIASES=(
  [skills]="$HOME/ai-agent-skills"
  [repos]="$HOME/repos"
  [next]="$HOME/repos-next"
)
```

Then add this parser to your `${ZENV}.aliases.zsh` file:

```zsh
_register_repo_aliases() {
  (( ${+REPO_ALIASES} )) || return 0

  local alias_name target_path
  for alias_name target_path in ${(kv)REPO_ALIASES}; do
    eval "alias ${alias_name}='cd ${target_path:q} && l'"
  done
}

_register_repo_aliases
unset -f _register_repo_aliases
```

Each key becomes the alias name, and each value becomes the `cd ... && l` target.

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

See `extras/examples/` for Dockerfiles, Docker Compose, and the quick reference.

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
