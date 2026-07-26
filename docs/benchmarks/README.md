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
host. `min` is the most meaningful number for a load-path budget — it is the closest
measurement to "just the code," with OS scheduling noise mostly averaged out; `p95`
tells you what a bad run looks like.

## Budget (from the guiding principles)

- Full interactive shell: **< 400 ms**
- Minimal profiles (`vscode`, `codex`, `docker-dev`): **< 150 ms**

**The current `baseline.json` does not meet this budget — by roughly 10x on every
profile.** Before concluding the config is 10x over budget, read the caveat below.

## Caveat: this baseline was captured in an AI-agent sandbox, not a real machine

The 2026-07-26 baseline was recorded by an AI coding agent running inside a sandboxed
execution environment (Claude Code), not the maintainer's actual daily-driver Mac.
Absolute numbers from a sandbox are not trustworthy for judging a millisecond budget:

- A p10k `gitstatusd` initialization failure was observed during profiling
  (`gitstatus failed to initialize`), which is itself a sign the sandbox's process/IPC
  environment differs from a real terminal.
- `zprof` showed `node --version` / `pnpm --version` costing ~1.5 seconds of self-time
  in `show-os-version-and-sys-info`, when either command alone measured ~17 ms in
  isolation in the same sandbox. That gap is consistent with resource contention
  specific to the sandbox at that moment, not a real per-shell cost.
- Bare process-spawn overhead in the sandbox measured normally (a few ms for
  `/bin/echo`, `zsh --version`), so the sandbox is not uniformly slow — something
  specific to this config's startup path is triggering contention or a failed
  fast-path there.

**What the baseline _does_ show reliably** — because it's a ratio between profiles run
in the same environment, not an absolute number — is the architecture working as
intended:

| Profile                                                       |     p50 (ms) | Why                                                                                                                      |
| ------------------------------------------------------------- | -----------: | ------------------------------------------------------------------------------------------------------------------------ |
| `codex`                                                       |       ~1,330 | `is-agent-shell` short-circuits `bootstrap/index.zsh` entirely — no antidote, no compinit, no p10k prompt.               |
| `docker-dev`                                                  |       ~1,680 | `is-container` skips antidote/plugin loading in bootstrap, but compinit/prompt still run.                                |
| `vscode`                                                      |       ~3,400 | `is-ide-shell` only short-circuits _`main.zsh`_'s later steps — bootstrap still pays full antidote/compinit/prompt cost. |
| `home-macos` / `office-macos` / `home-linux` / `server-linux` | ~4,500–5,500 | Full path, no early exit.                                                                                                |

That `vscode` pays the full bootstrap cost despite being a "minimal" profile is a real,
actionable finding independent of the sandbox — it is a candidate for
[P4.4](../todo/TODO_PUBLIC_RELEASE_REFACTOR.md#p44--structural-speedups).

**Before trusting absolute numbers against the 400ms/150ms budget, re-run this on a
real machine:**

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save
```

and commit the result as the authoritative baseline, replacing (or alongside, dated)
this one.
