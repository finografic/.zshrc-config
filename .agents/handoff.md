# Project — Handoff

> **How to maintain this file**
> Update after sessions that change architecture, add/remove features, resolve open questions, or shift priorities — not every session.
> — Update only the sections that changed. Keep the total under 150 lines.
> — Write in present tense. No code snippets — describe what exists, not how it works.
> — `.agents/memory.md` = chronological working memory / session log. `.agents/handoff.md` = current project state snapshot. See `docs/process/PROJECT_MEMORY_MODEL.md`.

## Project

Modular Zsh configuration (`zshrc-config`) that adapts to the host: one config tree, multiple environments (home-macos, office-macos, docker-dev, vscode, android, server-linux, codex), with environment-specific aliases, paths, and tooling loaded automatically.

## Architecture

`bootstrap/` runs first (profiling, Antidote plugin manager, plugin loading, compinit, prompt; `typeset -U path PATH` de-dupes `PATH` for the session), then `main.zsh` orchestrates: environment detection (`core/detect.zsh` + `core/env.zsh`) → theme → core zsh options/locale → the profile under `_zenvs/$ZENV/` → splash screen.

Profiles are **declarative manifests**, not `source` lists. A profile sets `ZENV_PRESET` (`full` / `minimal` / `container` / `none`), `ZENV_MODULES`, `ZENV_FEATURES`, `ZENV_OPT_IN` and calls `zenv-load`; `core/profile.zsh` resolves module names to `lib/` barrels in a canonical order, feature names to `$ZENV_PATH/$ZENV.<name>.zsh`, and opt-ins to `extras/`. Unknown names fail loudly. The `node` module owns the nvm/pnpm boot sequence so the "nvm before `lib/node.zsh`" invariant cannot be got wrong per-profile. `lib/` modules are inert on source (verified by `tests/test-lib-inert.zsh`); side effects live behind named functions a profile opts into.

Node is off the startup path entirely — `packages/node` is deleted; `packages/` is empty awaiting the Phase 5 `zconf` package. `tests/` holds four zsh test files, all run in CI. AI-agent context lives in `AGENTS.md` (entry point, linked from `CLAUDE.md`), `.github/instructions/**` (rule files, currently generic TS/React boilerplate — flagged for a zsh-specific rewrite), `.cursor/rules/`, and this `.agents/` memory pair, plus `docs/todo/ROADMAP.md` for milestone tracking.

## Status

The plan of record is `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md`. It sequences the work needed to take the repo public across Phases 0–8; nine open decisions (D1–D9) at the top of that doc have recommendations, and work proceeds on them unless corrected. Tasks are tagged `[OPUS]` (pause, suggest model switch) or `[HUMAN]` (stop, lay out steps, wait); untagged is Sonnet-tier.

**Phase 0**: done except **P0.1** (history/publish strategy, `[HUMAN]`, still open — the prerequisite before anything goes public). Secrets/PII scrubbed (IPs, a hardcoded SMB password, a deploy alias with a real server IP, tracked `.gitconfig`s, p10k caches), git-config-mutation and `gh auth login` removed from shell start, 66 MB of vendored binaries purged, `LICENSE`/`SECURITY.md`/`CONTRIBUTING.md`/CI added.

**Phase 1**: done. `core/detect.zsh` unifies environment detection (`is-container`, `is-agent-shell`, `is-ide-shell`, `determine-environment`), fixing an unreachable branch and two real bugs (an exported `ZENV` breaking nested-shell detection; a subshell discarding a resolved global) caught by `tests/test-detect.zsh`. Source-time side effects purged from `lib/` (`zclean`, `zdoctor` replace auto-running cleanup/security checks).

**Phase 2**: P2.1 done — `office-macos` genericised to a neutral ~30-line "work Mac" template (`lib/macos/macos.brew.zsh` now holds the Homebrew-prefix detection shared with `home-macos`); `_zenvs/apnaes` renamed to `_zenvs/server-linux` (7 files), with `chown-no`/`chown-ls`/`chown-apnaes` collapsed into one `chown-to [-R] [--dry-run]`, LSWS moved to an optional `server-linux.lsws.zsh` module (sourced only when `$LSWS_ROOT` exists), and the `edit`/`code` function bugs fixed. The `home-macos` `apnaes`-specific repo aliases now go through the existing `REPO_ALIASES` `.env` pattern instead of being hardcoded; the much larger `finografic`-branded alias block in the same file is untouched (out of scope — flagged for P7.1/P7.3). CI's secret-scan now enforces `apnaes` is gone; `finografic` stays out of the pattern since `@finografic/*` is a legitimate npm dependency scope as well as an org name. P2.2 built the manifest loader described in Architecture above and converted all eight profiles (entry points now 32–58 lines; `main.zsh` shed ~60 lines of unconditional sourcing, leaving `vendor/index.zsh` unused). P2.3 is largely absorbed by that conversion; what remains of it is per-profile content review, including one new finding — `home-linux`'s `hardware` feature probes real hardware at profile load and prints on every shell, which wants testing on an actual Linux desktop before changing.

**P4.3 done out of order** (Sonnet-tier), ahead of Phase 3, for the reason flagged above: `scripts/bench-startup.zsh` (+ `--all-profiles`/`--json`/`--save`, a TTY-gated spinner, streaming per-profile rows), one-command `zprof` via `ZSHRC_PROFILE=1`, a soft-fail CI ratio check, and `docs/benchmarks/baseline.json` + `README.md`. First captured in this AI agent's sandbox (which showed signs of startup-specific contention), **then superseded same-day by the maintainer's own real-Mac run, now the authoritative baseline**. Real numbers confirm the sandbox's shape: **~8–10x over the 400ms/150ms budget, genuinely, not a measurement artifact.** Ratios hold: `codex` (1,065ms p50) ≪ `docker-dev` (1,490ms) < `vscode` (2,910ms) ≪ full profiles (~4,200–4,250ms) — bootstrap early-exit architecture working as designed, and a real finding that `vscode`'s "minimal" profile still pays full `antidote`/`compinit`/prompt cost in `bootstrap/`, unlike `codex` (strong P4.4 candidate: give vscode/docker-dev the same bootstrap-level early exit). Two bugs found building the tool: `ZENV_FORCE` alone doesn't reach vscode/codex's fast paths (main.zsh's early exits test real env signals, not `$ZENV`); a bare `local name` redeclaration inside a `{ } > file` block triggers zsh's `typeset` display-mode and corrupted the first `--save` JSON output.

**Next: Phase 3** (`lib/` consolidation — mostly Sonnet-tier), then Phase 4's remaining performance work (**P4.4** is `[OPUS]` and explicitly wants a benchmark run between each change, so it depends on P4.3 having landed).

### Recent commits

- `687f0cb` docs: add project analysis and refactor plan
- `81b5194` build: add oxlint/oxfmt linting and formatting with husky commit hooks
- `08e9b5e` feat(markdown): genx audit used to add Markdown linting (@finografic/md-lint)
- `d3ce364` feat(ai-memory): genx audit used to add AI Memory (roadmap, handoff, session memory)
- `465d3fe` feat(ai-instructions): genx audit used to add AI Instructions (Copilot, Cursor rules)
- `f7362e8` feat(ai-agents): genx audit used to update AI Agents (AGENTS.md + skills)

## Key Decisions

- `oxlint` + `oxfmt` are the linting/formatting tools going forward; `dprint` is not used.
- Commit messages must follow Conventional Commits (`commitlint.config.mjs`); the existing `zupdate` auto-message (`updated from: $ZENV`) does not conform and is slated for rewrite (see analysis doc §5).
- `.agents/memory.md` is intentionally gitignored (session-local scratch); `.agents/handoff.md` is tracked and is the durable state snapshot.

## Open Questions

Decisions D1–D9 in `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md#decisions-needed-from-you` (git history strategy, `_zenvs/` → `profiles/` rename, profile manifest model, vendored binaries, Node on the startup path, where TypeScript lives, colors sourcing, source-time side effects, IP-based env detection). Each has a recommendation; none are confirmed.
