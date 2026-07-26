# Performance

## Budget

- Full interactive shell: **< 400 ms**
- Minimal profiles (`vscode`, `codex`, `docker-dev`): **< 150 ms**

No change lands that regresses either budget without a note in the commit
saying why.

## Current numbers

From `docs/benchmarks/baseline.json`, the maintainer's real-machine capture
(2026-07-26, Darwin arm64, n=20). **Read `p50`, not `min`** — a single fast run
poisons `min` without being representative; see
[`docs/benchmarks/README.md`](./benchmarks/README.md#reading-baselinejson) for
why.

| Profile        | p50 (ms) | vs. budget                                                              |
| -------------- | -------: | ----------------------------------------------------------------------- |
| `codex`        |     55.8 | ✅ under 150 ms                                                         |
| `vscode`       |    231.2 | over the 150 ms minimal-profile target                                  |
| `docker-dev`   |    497.4 | over 150 ms — not yet given `codex`'s bootstrap-level early exit        |
| `server-linux` |    470.1 | close to the 400 ms full-profile target                                 |
| `android`      |    490.9 | over 400 ms                                                             |
| `home-macos`   |    547.4 | over 400 ms — the ~475 ms splash, kept on by choice, is most of the gap |
| `office-macos` |    549.3 | over 400 ms                                                             |
| `home-linux`   |    799.8 | over 400 ms                                                             |

`codex` meets its budget outright by getting a full early exit from
`bootstrap/index.zsh` itself (see `core/detect.zsh`'s `is-agent-shell`). The
other profiles over budget are mostly paying for the splash (~475 ms,
deliberately opt-out rather than opt-in — see the change log) or not yet
having the same bootstrap-level early exit `codex` has.

## How to measure

```sh
scripts/bench-startup.zsh --all-profiles -n 20 --save   # refresh baseline.json
scripts/bench-startup.zsh --zenv home-macos -n 20        # one profile, table
scripts/bench-startup.zsh --zenv codex -n 20 --json       # machine-readable

# per-function breakdown of where time goes in one shell
ZSHRC_PROFILE=1 zsh -i -c exit

# zconf wraps the same script and diffs against the recorded baseline
pnpm zconf bench --profile home-macos
```

CI's `startup-budget` job asserts a **ratio**, not an absolute number —
`codex` must be meaningfully faster than a full profile. Absolute numbers from
a shared, virtualised CI runner are not trustworthy on their own; see
`docs/benchmarks/README.md` for the sandbox-vs-real-hardware evidence that
led to that decision.

## Full history

The complete change log — what was found, what was measured before and after,
and every verification — lives in
[`docs/benchmarks/README.md`](./benchmarks/README.md). The headline entry: the
`lukechilds/zsh-nvm` Antidote plugin was loading nvm a second time on top of
`vendor/nvm.zsh`'s own load, costing ~65% of every non-`codex` profile's
startup time — found by phase-by-phase `zprof` instrumentation, not by
guessing.
