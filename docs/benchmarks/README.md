# Startup benchmarks

`scripts/bench-startup.zsh` measures cold interactive-shell startup: min/p50/p95
wall-clock time for `zsh -i -c exit` (or the equivalent trigger for `vscode`/`codex`/
`docker-dev` — see the note in the script), i.e. the full load path with no work done
beyond it.

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save   # writes baseline.json
scripts/bench-startup.zsh --zenv home-macos -n 20        # one profile, table output
scripts/bench-startup.zsh --zenv codex -n 20 --json       # machine-readable
```

For a per-function breakdown of where time goes in one shell:

```sh
ZSHRC_PROFILE=1 zsh -i -c exit
```

## Reading `baseline.json`

Each profile's `min`/`p50`/`p95` in milliseconds, plus the run count, capture date, and
host.

**Use `p50` as the headline number.** `min` looks appealing ("closest to just the code")
but is fragile: a single anomalous run poisons it, and it cannot be distinguished from a
real result. The 2026-07-26 pre-change capture shows exactly this — `home-macos` recorded
`min 414.2` against `p50 4426.9`, and `office-macos` `min 289.8` against `p50 4656.2`.
A 10x spread like that is not a fast shell, it is a shell that never fully started (or a
scheduling artifact). `p50` is robust to both; `p95` tells you what a bad run looks like.

## Budget (from the guiding principles)

- Full interactive shell: **< 400 ms**
- Minimal profiles (`vscode`, `codex`, `docker-dev`): **< 150 ms**

**The current `baseline.json` does not meet this budget — by roughly 8–10x on every
profile.** This is now a _real-machine_ measurement (see history below), so that gap is
real and is Phase 4's actual work, not a measurement artifact to explain away.

## Provenance

- **2026-07-26, first capture**: recorded by an AI coding agent inside a sandboxed
  execution environment (Claude Code), not a real machine. That run showed clear signs of
  sandbox-specific contention — a p10k `gitstatusd` init failure, and `node --version`
  costing ~1.5s of `zprof` self-time when the same command measured ~17ms standalone in
  the same sandbox — so its absolute numbers were never trusted, only its cross-profile
  ratios.
- **2026-07-26, superseding capture (current `baseline.json`)**: re-run by the maintainer
  on their real Mac (`scripts/bench-startup.zsh --all-profiles -n 20 --save`), overwriting
  the sandbox numbers. **These are real-machine numbers, and they are the PRE-change
  reference** — captured before the `zsh-nvm` removal in the change log below. They confirm
  the sandbox run's shape at lower absolute cost, and the same conclusion: this config was
  genuinely far over budget, not merely measured in a slow environment.

  ⚠️ **This file is now stale as a description of current performance.** It predates a
  change measured at ~65% faster. Re-run `--all-profiles -n 20 --save` to refresh it.

**What both captures show, consistently** — the bootstrap early-exit architecture working
as designed:

| Profile                                      | p50 (ms, real Mac, pre-change) | Why                                                                                                                      |
| -------------------------------------------- | -----------------------------: | ------------------------------------------------------------------------------------------------------------------------ |
| `codex`                                      |                          1,209 | `is-agent-shell` short-circuits `bootstrap/index.zsh` entirely — no antidote, no compinit, no p10k prompt.               |
| `docker-dev`                                 |                          1,548 | `is-container` skips antidote/plugin loading in bootstrap, but compinit/prompt still run.                                |
| `android`                                    |                          2,829 | `container` preset; no bootstrap early exit.                                                                             |
| `vscode`                                     |                          3,033 | `is-ide-shell` only short-circuits _`main.zsh`_'s later steps — bootstrap still pays full antidote/compinit/prompt cost. |
| `server-linux`                               |                          3,971 | Full path, no early exit.                                                                                                |
| `home-macos` / `office-macos` / `home-linux` |                   ~4,400–4,700 | Full path, no early exit.                                                                                                |

That `vscode` pays the full bootstrap cost despite being a "minimal" profile — 3,033ms vs
`codex`'s 1,209ms, both of which should be fast — is the clearest actionable finding here.
It's a strong candidate for
[P4.4](../todo/TODO_PUBLIC_RELEASE_REFACTOR.md#p44--structural-speedups): giving `vscode`
(and `docker-dev`) the same `bootstrap/index.zsh`-level early exit `codex` already gets,
rather than only skipping `main.zsh`'s later steps.

## Change log

### 2026-07-26 — removed the `lukechilds/zsh-nvm` plugin (P4.4)

**The single largest win found so far: ~65% off every non-`codex` profile.**

Phase-by-phase instrumentation showed `bootstrap/02-plugins.zsh` — sourcing the generated
antidote bundle — was **1,218 ms of a 1,251 ms bootstrap (97%)**. Timing each plugin in
that bundle individually narrowed it to two: `lukechilds/zsh-nvm` (616 ms) and
`ohmyzsh/plugins/yarn` (547 ms).

The root cause was **nvm being loaded twice per shell**. `zsh-nvm` sources nvm itself
during bootstrap, and `vendor/nvm.zsh` sources `$NVM_DIR/nvm.sh` again later via the
manifest's `node` module. nvm is inherently expensive to load — measured in isolation:

| Operation                         |   Cost |
| --------------------------------- | -----: |
| `source $NVM_DIR/nvm.sh`          | 438 ms |
| `nvm version default`             | 190 ms |
| `source $NVM_DIR/bash_completion` |  66 ms |
| `nvm version`                     |  64 ms |

`NVM_LAZY_LOAD` is **not** a fix — measured at 490 ms unset / 597 ms true / 515 ms false.
The cost is `nvm.sh` itself, not eagerness. (It was also set in `vendor/nvm.zsh`, which
runs _after_ bootstrap, so it could never have influenced the plugin anyway.)

Nothing in this repo referenced the plugin's own features (`NVM_AUTO_USE`, `_zsh_nvm_*`),
and the config already owns the whole nvm lifecycle: `vendor/nvm.zsh` for loading and the
per-environment default version, `lib/node/nvm-autoload.zsh` for `.nvmrc` switching via a
`chpwd` hook. So the plugin was pure duplication.

A/B, same environment, back-to-back, n=8:

| Profile      | with `zsh-nvm` |      without |    delta |
| ------------ | -------------: | -----------: | -------: |
| `home-macos` |       5,656 ms | **1,993 ms** | **−65%** |
| `vscode`     |       3,707 ms | **1,389 ms** | **−63%** |

The plugin bundle itself went from **1,228 ms → 103 ms**. `yarn` fell from 547 ms to 49 ms
as a side effect: `yarn` is an nvm-shimmed binary, so the yarn plugin's `yarn global bin`
shell-out was itself paying the double-loaded-nvm tax.

Verified unchanged after the removal: `nvm` is a function, `nvm_find_nvmrc` and
`load-nvmrc` exist, the `chpwd` hook is registered, `.nvmrc` auto-switching still fires
("Found .nvmrc with version <24.16.0>"), and node/npm/pnpm/yarn all resolve. A pre-existing
quirk (`nvm current: system`, and `node --version` not reflecting the `.nvmrc` switch within
the same command list) was confirmed identical _before_ the change, so it is unrelated.

> **These deltas were measured in an AI-agent sandbox.** The percentages should hold on real
> hardware since it is a same-environment A/B, but `baseline.json` above is still the
> maintainer's _pre-change_ real-machine capture. Re-run `--all-profiles -n 20 --save` on a
> real machine to record the new absolute numbers.

To re-run and refresh the baseline after a change:

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save
```
