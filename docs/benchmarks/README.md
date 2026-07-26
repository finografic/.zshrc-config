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

**`baseline.json` now reflects the post-P4.4 state and meets the minimal-profile budget for
`codex`** (~56 ms, well under 150 ms); the full profiles are close to the 400 ms target and
would be under it with the splash off (kept on by choice — see the splash change log entry).

## Provenance

- **2026-07-26, first capture**: recorded by an AI coding agent inside a sandboxed
  execution environment (Claude Code), not a real machine. That run showed clear signs of
  sandbox-specific contention — a p10k `gitstatusd` init failure, and `node --version`
  costing ~1.5s of `zprof` self-time when the same command measured ~17ms standalone in
  the same sandbox — so its absolute numbers were never trusted, only its cross-profile
  ratios.
- **2026-07-26, real-machine pre-change capture**: re-run by the maintainer on their real
  Mac before any P4.4 work landed. Confirmed the sandbox run's shape at lower absolute
  cost, and the same conclusion: this config was genuinely far over budget, not merely
  measured in a slow environment. (No longer current — see below.)
- **2026-07-26, real-machine post-change capture (current `baseline.json`)**: re-run by the
  maintainer after the `zsh-nvm` removal, splash caching, and lazy nvm all landed
  (`scripts/bench-startup.zsh --all-profiles -n 20 --save`). Matches the sandbox A/B
  percentages: `codex` ~56 ms, `home-macos` ~547 ms — both close to or better than the
  sandbox predicted. **This is the current, authoritative baseline.**

**What all three captures show, consistently** — the bootstrap early-exit architecture
working as designed. Pre-change numbers below; see the change log for post-change figures.

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

> **These deltas were measured in an AI-agent sandbox.** Confirmed on real hardware
> afterwards — see the post-change capture in Provenance above, which matches this A/B's
> percentages closely (`home-macos` landed even faster than the sandbox predicted).

### 2026-07-26 — splash made opt-OUT (P4.4)

The splash measured ~475 ms, per widget: `show-os-version-and-sys-info` 181 ms
(`node`/`pnpm --version`), `show-ports` 76 ms (`lsof`), `show-tmutil-snapshots` 73 ms,
`show-splash-neofetch` 48 ms, `show-custom-launch-agents` 36 ms.

`ZSHRC_SPLASH=0` disables it; **anything else, including unset, shows it** — for every
interactive shell, nested ones included. The only unconditional skip is a non-interactive
shell, where a banner would corrupt piped output.

> **Corrected same day.** The first version of this gate defaulted to "outermost interactive
> shell only" (login shell, or `SHLVL` 1), on the theory that a splash in the second and
> third nested shell is waste. The maintainer immediately hit it: typing `zsh` in an existing
> terminal showed nothing, and needed `ZSHRC_SPLASH=1` to force. That is the right
> correction — typing `zsh` is a deliberate act and the splash is its expected result. The
> performance argument does not outrank what the config's owner wants their shell to do;
> the cost is opt-out, not opt-in.
>
> Consequence: **this change now saves nothing by default.** It is a switch for people who
> want one (and for `docker`/CI images), not a startup win. The ~475 ms is still paid on
> every interactive shell, and remains the largest single target left after `nvm.sh`.

`bench-startup.zsh` still forces `ZSHRC_SPLASH=1` explicitly, so the benchmark cannot drift
if that default is ever revisited.

### 2026-07-26 — nvm no-op guards (P4.4)

Sourcing `vendor/nvm.zsh` measured **1,217 ms from `$HOME`** vs 505 ms inside a repo. The
712 ms difference is `nvm use` (~478 ms) and `nvm alias default` (~260 ms), which run only
in the no-`.nvmrc` branch — the ordinary case of opening a terminal in `$HOME`, making the
expensive path the common one.

Both were no-ops in the steady state: sourcing `nvm.sh` already activates the default
version, so `NVM_BIN`, `nvm current` and `alias/default` are all correct _before_ those two
commands run. They are now guarded by an equivalent check costing microseconds (a parameter
test plus one small file read); nvm is invoked only when something genuinely differs.

Verified it still _repairs_ a wrong state rather than merely skipping work: with
`alias/default` deliberately set to a stale `20.0.0`, sourcing the file correctly invoked
nvm and restored `24.16.0`.

**1,217 → ~499 ms from `$HOME` (−59%)**, same resolved node version.

### 2026-07-26 — lazy nvm (P4.4)

`source $NVM_DIR/nvm.sh` was ~449 ms plus ~58 ms for its `bash_completion` — the largest
single item left on the startup path, paid by every shell to arrive at a state it could
have had for free: the default Node version active.

`vendor/nvm.zsh` now reads `$NVM_DIR/alias/default` (a one-line file), puts that version's
`bin` directory straight on `PATH`, and does **not** source `nvm.sh`. Everything in that
directory — `node`, `npm`, `npx`, `pnpm`, `yarn`, `corepack` — works immediately. `nvm.sh`
is sourced on demand: the first time `nvm` is called, or the first time `load-nvmrc` finds
an `.nvmrc` wanting a _different_ version than the one already active.

That last condition is what makes it pay off. `load-nvmrc` now compares the wanted version
against `$NVM_BIN` first, so the common case — an `.nvmrc` matching the default — resolves
with no subprocess and no nvm load at all.

The fast path is only taken when `alias/default` is a plain `X.Y.Z` that is actually
installed. An alias like `lts/*`, or a missing version, falls through to the original eager
behaviour, so an unusual setup degrades rather than silently ending up without Node.
`ZSHRC_NVM_LAZY=0` forces the eager path.

Verified across every scenario, not just the fast one:

| Scenario                               | node       | `nvm.sh` sourced |    time |
| -------------------------------------- | ---------- | ---------------- | ------: |
| `$HOME`, no `.nvmrc` (the common case) | `v24.16.0` | no               |  2.5 ms |
| `.nvmrc` matches the default           | `v24.16.0` | no               |  3.0 ms |
| `.nvmrc` differs → must really switch  | `v22.17.1` | yes, on demand   | 1310 ms |
| `ZSHRC_NVM_LAZY=0` escape hatch        | `v24.16.0` | yes, eagerly     |  584 ms |

Plus the actual daily workflow — `cd` between directories: start (no `.nvmrc`) →
`v24.16.0`, into `.nvmrc 22.17.1` → `v22.17.1`, into `.nvmrc 24.16.0` → `v24.16.0`, back to
`$HOME` → reverts to `v24.16.0`. All correct. `npm` and `pnpm` resolve in every case, and
the `nvm` command itself works through the stub.

**2.5 ms vs 584 ms on the common path — the eager load is now only paid when a version
actually has to change.**

### Cumulative so far (sandbox, n=10, splash forced on)

| Profile        | session start |    now |    delta | vs budget       |
| -------------- | ------------: | -----: | -------: | --------------- |
| `codex`        |     ~1,340 ms |  63 ms | **−95%** | ✅ under 150 ms |
| `vscode`       |      3,707 ms | 225 ms | **−94%** | over 150 ms     |
| `server-linux` |     ~4,300 ms | 424 ms | **−90%** | ~at 400 ms      |
| `docker-dev`   |     ~1,680 ms | 477 ms | **−72%** | over 150 ms     |
| `android`      |     ~3,100 ms | 499 ms | **−84%** | over 400 ms     |
| `office-macos` |     ~5,300 ms | 552 ms | **−90%** | over 400 ms     |
| `home-macos`   |      5,656 ms | 553 ms | **−90%** | over 400 ms     |
| `home-linux`   |     ~5,100 ms | 778 ms | **−85%** | over 400 ms     |

Measured with `ZSHRC_SPLASH=1`, so the full profiles are still paying the ~475 ms splash
that was deliberately kept on by default. `codex` now **meets** the 150 ms minimal-profile
budget outright; the full profiles are within striking distance of 400 ms and would already
be under it with the splash off.

Remaining, roughly by size: the splash (~475 ms, kept by choice), the antidote plugin bundle
(~97 ms), `compinit` (~22 ms), and parsing the eager `lib/` barrels — the last being what
`autoload`/`zcompile` would address, still not done.

To re-run and refresh the baseline after a change:

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save
```
