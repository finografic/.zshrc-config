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
  the sandbox numbers. **These are the authoritative numbers.** They land faster than the
  sandbox run (full profiles ~4.1–4.4s vs ~4.3–5.6s there) but confirm the same shape and
  the same conclusion: this config is genuinely far over budget, not just measured in a
  slow environment.

**What both captures show, consistently** — the bootstrap early-exit architecture working
as designed:

| Profile                                      | p50 (ms, real Mac) | Why                                                                                                                      |
| -------------------------------------------- | -----------------: | ------------------------------------------------------------------------------------------------------------------------ |
| `codex`                                      |              1,065 | `is-agent-shell` short-circuits `bootstrap/index.zsh` entirely — no antidote, no compinit, no p10k prompt.               |
| `docker-dev`                                 |              1,490 | `is-container` skips antidote/plugin loading in bootstrap, but compinit/prompt still run.                                |
| `android`                                    |              2,670 | `container` preset; no bootstrap early exit.                                                                             |
| `vscode`                                     |              2,910 | `is-ide-shell` only short-circuits _`main.zsh`_'s later steps — bootstrap still pays full antidote/compinit/prompt cost. |
| `server-linux`                               |              3,621 | Full path, no early exit.                                                                                                |
| `home-macos` / `office-macos` / `home-linux` |       ~4,200–4,250 | Full path, no early exit.                                                                                                |

That `vscode` pays the full bootstrap cost despite being a "minimal" profile — 2,910ms vs
`codex`'s 1,065ms, both of which should be fast — is the clearest actionable finding here.
It's a strong candidate for
[P4.4](../todo/TODO_PUBLIC_RELEASE_REFACTOR.md#p44--structural-speedups): giving `vscode`
(and `docker-dev`) the same `bootstrap/index.zsh`-level early exit `codex` already gets,
rather than only skipping `main.zsh`'s later steps.

To re-run and refresh the baseline after a change:

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save
```
