# Profiles

A profile is a declarative manifest for one kind of host, not a script. This
is the reference for what a manifest can say, and a worked walkthrough for
adding your own.

See [`docs/ARCHITECTURE.md`](./ARCHITECTURE.md) for how profiles fit into the
boot sequence as a whole.

## The manifest

```zsh
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/profiles/$ZENV"

ZENV_PRESET=full                 # full | minimal | container | none
ZENV_MODULES=(llms macos ghostty)
ZENV_FEATURES=(backups aliases dev)
ZENV_OPT_IN=(music/backup-dj-crate)

zenv-load
```

| Field           | What it does                                                                                                                     |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `ZENV_PRESET`   | A named bundle of modules — see below. Every preset already includes `colors`, so you rarely need it in `ZENV_MODULES` directly. |
| `ZENV_MODULES`  | Extra `lib/` barrels beyond what the preset gives you, e.g. `macos`, `ghostty`, `llms`.                                          |
| `ZENV_FEATURES` | Profile-local files: each name `x` resolves to `$ZENV_PATH/$ZENV.x.zsh` (e.g. `aliases` → `home-macos.aliases.zsh`).             |
| `ZENV_OPT_IN`   | Files under `extras/`, e.g. `music/backup-dj-crate` → `extras/music/backup-dj-crate.zsh`. Never implied by a preset.             |

Everything is resolved by `core/profile.zsh`'s `zenv-load`, which owns two
things a profile is not trusted with:

- **Load order.** Modules load in the registry's canonical order regardless of
  how you listed them — `colors` always precedes anything using `${_c}`.
- **The nvm invariant.** Requesting the `node` module gets you the
  `vendor/nvm.zsh` → `vendor/pnpm-path.zsh` → `lib/node.zsh` sequence, in that
  order, every time (pnpm-path last, so its prepend of `$PNPM_HOME/bin` lands
  in front of `$NVM_BIN` and pnpm's self-managed binary wins). Three profiles
  used to hand-roll this differently; now it can't be gotten wrong per-profile.

An unknown module, feature, or preset name is a loud failure at shell start,
never a silent skip.

## Presets

| Preset      | Modules                                                              | Intent                                      |
| ----------- | -------------------------------------------------------------------- | ------------------------------------------- |
| `full`      | `colors paths common utils disk doctor fzf git node dev clean zconf` | A personal, interactive terminal.           |
| `minimal`   | `colors git node dev`                                                | IDE/agent shells — fast, still useful.      |
| `container` | `colors utils git node dev`                                          | Minimal minus anything macOS/host-specific. |
| `none`      | (empty)                                                              | You list everything explicitly.             |

`splash` and `ghostty` are in the module registry but deliberately absent from
every preset: `main-splash.zsh` sources `splash` directly (listing it in a
preset would double-source it), and `ghostty` hardcodes a macOS config path so
it isn't OS-agnostic enough to default on.

## The eight profiles today

| Profile        | Preset      | Notable features/opt-ins                                                                |
| -------------- | ----------- | --------------------------------------------------------------------------------------- |
| `home-macos`   | `full`      | `macos`, `ghostty`, `llms` modules; backups, aliases, dev features; djay/iCloud opt-ins |
| `office-macos` | `full`      | `macos`, `ghostty` modules; a generic aliases/dev template                              |
| `server-linux` | `full`      | An `lsws` feature, sourced only when `$LSWS_ROOT` exists                                |
| `home-linux`   | `full`      | The reference generic-Linux-desktop profile                                             |
| `docker-dev`   | `container` | No macOS assumptions; Antidote/plugins skipped in `bootstrap/`                          |
| `vscode`       | `minimal`   | Early exit from `main.zsh` — no theme, splash, or options step                          |
| `codex`        | `none`      | Early exit from `main.zsh`; explicit `colors node` modules only                         |
| `android`      | `container` | Termux — no nvm (Termux's own node build isn't nvm-compatible)                          |

`vscode` and `codex` are reached via an early return in `main.zsh` (see the
boot-sequence diagram in `docs/ARCHITECTURE.md`), not through the normal
`profiles/$ZENV/$ZENV.zsh` step — they never see the theme, `core/options.zsh`,
`core/locale.zsh`, or splash.

## How `$ZENV` gets chosen

`core/detect.zsh`'s `determine-environment`, in this order:

1. `$ZENV_FORCE` — an explicit override (`ZENV_FORCE=server-linux zsh`, used
   for testing and CI)
2. Agent shell (Codex) → `codex`
3. IDE terminal (VS Code) → `vscode`
4. Container → `docker-dev`
5. `.env` flags: `IS_HOME` / `IS_OFFICE` / `IS_SERVER`
6. OS-based fallback (`macOS` → `home-macos`, `Android` → `android`, else
   `home-linux`)

Note what it reads: `$ZENV_FORCE`, never the exported `$ZENV` itself — `$ZENV`
is inherited by every nested shell, so honouring it directly would make a VS
Code terminal opened from a normal shell never resolve to `vscode`.

## Adding a new profile

**The fast path:**

```console
$ pnpm zconf new-profile work-linux --preset minimal --features dev,aliases
✔ created profiles/work-linux/
  profiles/work-linux/work-linux.zsh
  profiles/work-linux/work-linux.dev.zsh
  profiles/work-linux/work-linux.aliases.zsh
```

The scaffold already passes `zconf doctor` and is already canonically
formatted. From there:

1. **Fill in the templates.** `work-linux.zsh` has the manifest; the feature
   files are stubs with `lib/colors.zsh` already sourced.
2. **Teach `core/detect.zsh` when to select it**, if it should be reachable
   without `$ZENV_FORCE`. Usually a new `.env` flag
   (`IS_WORK:-false`) added to the flags block in `determine-environment`.
3. **Run `pnpm zconf doctor`** — it validates the manifest against the real
   module registry, so a typo'd module name fails here, not at shell start on
   whatever machine actually uses the profile.
4. **Boot it for real**: `ZENV_FORCE=work-linux zsh -i` and confirm the prompt,
   aliases, and any feature-specific behaviour look right.
5. **Add it to `tests/test-profile-boot.zsh`** if it's meant to be a
   first-class, CI-verified profile rather than a personal one-off.

**By hand**, the same shape without the generator: a directory under
`profiles/<name>/` containing `<name>.zsh` (the manifest) and one file per
feature named `<name>.<feature>.zsh`. Copy an existing small profile
(`android/` is the shortest) rather than starting from a blank file.

## Why not just `--preset full` for everything?

`full` pulls in `dev`, `clean`, `doctor` and other modules meant for an
interactive human at a keyboard — real weight for a shell that's never
interactive (CI, a minimal container, an agent). `minimal`/`container`/`none`
exist so a profile carries only what it needs; see the startup-budget section
of `docs/ARCHITECTURE.md` for why that weight is measured, not assumed.
