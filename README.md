# 💻 zshrc-config

**One config tree, eight host profiles, auto-detected.** Open a terminal on
your Mac, your work Mac, a Linux box, inside Docker, in VS Code, or as a
Codex agent shell — the same repo picks the right profile and gets out of
the way. Startup is measured, not assumed: a Codex agent shell boots in
**~56 ms**; a full interactive terminal in **~550 ms**.

---

## Try it in 30 seconds

No install, no touching your real `~/.zshrc` — mount the repo into a
throwaway container and it auto-detects Docker and loads `profiles/docker-dev/`:

```bash
docker run -it --rm \
  -v ~/.zshrc-config:/root/.zshrc-config:ro \
  -v ~/.zshrc:/root/.zshrc:ro \
  -v $(pwd):/workspace \
  zsh-dev:latest
```

See `extras/examples/` for the Dockerfile, Compose file, and quick reference.

---

## Philosophy

- **Detect, don't ask.** `.env` flags (or the machine's OS as a fallback) pick
  the right `profiles/` entry — no manual profile switching.
- **A budget, not a guess.** Full interactive shell < 400 ms, minimal
  profiles (vscode/codex/docker) < 150 ms, measured by
  `scripts/bench-startup.zsh` and checked in CI.
- **`~/.zshrc` stays minimal.** Everything else lives in this repo, so it's
  one `git pull` away on every machine.
- **Sourcing a module never does anything.** `lib/` is definitions-only;
  side effects live behind named functions a profile opts into. Enforced by
  `zconf doctor`, not just convention — see `docs/ARCHITECTURE.md`.
- **Multi-system sync** via `zupdate` — safe staging, a real commit message,
  a secret scan before every push.
- **Legible to AI coding agents**, not just humans: `AGENTS.md`, `.agents/`,
  `docs/`.

## Startup, measured

| Profile      | p50 (ms) | Budget                         |
| ------------ | -------: | ------------------------------ |
| `codex`      |     55.8 | ✅ under 150 ms                |
| `vscode`     |    231.2 | minimal-profile target: 150 ms |
| `home-macos` |    547.4 | full-profile target: 400 ms    |

Full numbers for all 8 profiles, how to reproduce them, and the change log
behind the biggest win (removing a plugin that was loading `nvm` twice, for a
65% cut): `docs/PERFORMANCE.md`.

---

## Quick setup

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

Create `.env` with `IS_HOME`, `IS_OFFICE`, or `IS_SERVER` as needed so the
right `profiles/` entry loads — see `docs/PROFILES.md` for the full
precedence order and how a profile is resolved without any flags at all.

---

## Make it yours

- **`.env` flags** (above) pick your profile without editing tracked files.
- **`pnpm zconf new-profile <name>`** scaffolds a new host profile from
  templates that already pass `zconf doctor` — see the walkthrough in
  `docs/PROFILES.md`.
- **The alias registry** (below) keeps your personal repo paths out of
  tracked shell files entirely.

---

## Structure

The full directory tree, the layer contract, and the auto-generated load
graph live in **[`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md)** — the
short version: `bootstrap/` (ordered init) → `main.zsh` (detects `$ZENV`,
early-exits for agent/IDE shells) → `profiles/$ZENV/$ZENV.zsh` (a manifest,
resolved by `core/profile.zsh`) → splash.

```
~/.zshrc-config/
├── bootstrap/          # Early init: profiling, Antidote, plugins, compinit, p10k
├── core/               # env detection, zsh options, history, keybindings, locale
├── lib/                # colors, utils, node/, clean/, dev, git, fzf — definitions only
├── vendor/             # pnpm, nvm init/PATH
├── profiles/           # One directory per host — see docs/PROFILES.md
├── packages/zconf/     # Maintainer CLI (TypeScript): doctor, scan, graph, bench, normalize
├── extras/             # music/, hardware/, examples/ — optional, never auto-sourced
├── docs/               # ARCHITECTURE.md, PROFILES.md, PERFORMANCE.md, CONVENTIONS.md
├── main.zsh            # Orchestrator
├── bin/zupdate         # launcher; symlink to ~/bin/zupdate
└── update-config.zsh   # zupdate implementation
```

---

## Features

| Feature                   | Description                                                                      |
| ------------------------- | -------------------------------------------------------------------------------- |
| **Environment detection** | `.env` flags (or OS fallback) → the matching `profiles/` entry, no manual switch |
| **Bootstrap**             | Antidote, plugins, compinit, p10k — correct load order, enforced in one place    |
| **Fast IDE/agent shells** | `codex`/`vscode` early-exit `main.zsh`; `codex` also skips `bootstrap/` entirely |
| **Lazy nvm**              | `.nvmrc`-aware; `nvm.sh` itself loads only when a real version switch is needed  |
| **`zconf`**               | Maintainer CLI — lints the load-model contract, scans for secrets, diffs startup |
| **`zupdate`**             | Safe staging, a conventional-commit message, a secret scan, before every push    |
| **Lint/format**           | `oxlint` + `oxfmt` + `commitlint`, enforced locally (Husky) and in CI            |
| **AI-agent docs**         | `AGENTS.md` entry point, `.agents/` memory, `docs/todo/ROADMAP.md`               |

---

## Scripts

| Command                                         | Purpose                                                              |
| ----------------------------------------------- | -------------------------------------------------------------------- |
| `scripts/install-zshrc-config-dependencies.zsh` | Install Homebrew, Antidote, p10k, fzf, Meslo font                    |
| `zupdate`                                       | Commit and push with `fetch` + `pull --rebase` for multi-system sync |
| `pnpm zconf doctor`                             | Lint the repo against the load-model contract                        |
| `pnpm zconf scan`                               | Scan tracked files for secrets and PII                               |
| `pnpm zconf graph --profile <name>`             | Show a profile's resolved load order (or mermaid for the whole tree) |
| `pnpm zconf new-profile <name>`                 | Scaffold a new host profile                                          |
| `pnpm zconf normalize`                          | Normalise comment blocks and function style                          |
| `pnpm zconf bench --profile <name>`             | Measure startup and diff against the recorded baseline               |
| `pnpm lint` / `pnpm lint:fix`                   | Run `oxlint` (optionally with `--fix`)                               |
| `pnpm format:check` / `pnpm format:fix`         | Run `oxfmt` in check or write mode                                   |
| `pnpm lint:md` / `pnpm lint:md:fix`             | Markdown lint via `@finografic/md-lint`                              |

### `zupdate`

Run from anywhere — `ln -sf ~/.zshrc-config/bin/zupdate ~/bin/zupdate`.

```bash
zupdate "tidy up the git aliases"   # gets a `chore: ` prefix if it has no type
zupdate                             # opens $EDITOR, like `git commit`
zupdate --sync                      # chore(sync): update from <profile>
zupdate --dry-run                   # show what would happen; change nothing
```

It stages **tracked changes only** (`git add -u`). Untracked files are listed
with their sizes and require `--all`, so a stray large file cannot be swept in.
Every message it produces satisfies the commitlint hook, and it runs a secret
scan before pushing — `zconf scan` when Node is available, a dependency-free
grep otherwise, so the check still happens on a bare server.

---

## Alias registry

Keep local repo paths out of tracked shell files by defining an alias map in
`.env`. Because `.env` is sourced by zsh, associative arrays work.

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
function _register-repo-aliases() {
  (( ${+REPO_ALIASES} )) || return 0

  local alias_name target_path
  for alias_name target_path in ${(kv)REPO_ALIASES}; do
    eval "alias ${alias_name}='cd ${target_path:q} && l'"
  done
}

_register-repo-aliases
unset -f _register-repo-aliases
```

Each key becomes the alias name, and each value becomes the `cd ... && l` target.

---

## Troubleshooting

**`zsh compinit: insecure directories`**

```zsh
compaudit                    # list insecure dirs
sudo chown -R $USER /path    # fix ownership
```

**Profiling startup**

```zsh
scripts/bench-startup.zsh --all-profiles -n 20   # min/p50/p95 per profile
ZSHRC_PROFILE=1 zsh -i -c exit                    # per-function zprof breakdown
pnpm zconf bench --profile home-macos             # wraps the above, diffs the baseline
```

---

## Docs

- [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) — layers, the side-effect rule, `PATH` ownership, the load graph.
- [`docs/PROFILES.md`](./docs/PROFILES.md) — the manifest reference and a worked "add your own host" walkthrough.
- [`docs/PERFORMANCE.md`](./docs/PERFORMANCE.md) — the budget, current numbers, and how to measure.
- [`docs/CONVENTIONS.md`](./docs/CONVENTIONS.md) — the zsh style rules `zconf doctor` enforces, explained.
- [`AGENTS.md`](./AGENTS.md) — entry point for AI coding agents working in this repo.

---

_By Justin Rankin_
