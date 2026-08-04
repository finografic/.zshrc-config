# Project — Handoff

> **How to maintain this file**
> Update after sessions that change architecture, add/remove features, resolve open questions, or shift priorities — not every session.
> — Update only the sections that changed. Keep the total under 150 lines.
> — Write in present tense. No code snippets — describe what exists, not how it works.
> — `.agents/memory.md` = chronological working memory / session log. `.agents/handoff.md` = current project state snapshot. See `docs/process/PROJECT_MEMORY_MODEL.md`.

## Project

Modular Zsh configuration (`zshrc-config`) that adapts to the host: one config tree, eight environments (home-macos, office-macos, home-linux, server-linux, docker-dev, vscode, codex, android), auto-detected, with environment-specific aliases, paths, and tooling.

## Architecture

`bootstrap/` runs first (profiling, Antidote, plugins, compinit, prompt; `typeset -U path PATH` de-dupes `PATH` once for the session), then `main.zsh` orchestrates: environment detection (`core/detect.zsh` + `core/env.zsh`, resolving `$ZENV` exactly once) → early exit for agent/IDE shells → theme → core zsh options/locale → the profile under `profiles/$ZENV/` → splash.

Profiles are **declarative manifests**, not `source` lists — `ZENV_PRESET`/`ZENV_MODULES`/`ZENV_FEATURES`/`ZENV_OPT_IN`, resolved by `core/profile.zsh`'s `zenv-load`. Unknown names fail loudly. `lib/` is inert on source (proven by `tests/test-lib-inert.zsh`, linted statically by `zconf doctor`); side effects live behind named functions a profile opts into.

The maintainer CLI, `packages/zconf` (TypeScript, tsdown, vitest), is invoked deliberately and is never on the startup path — the shell works with no Node installed. Full detail: `docs/ARCHITECTURE.md`, `docs/PROFILES.md`, `docs/PERFORMANCE.md`, `docs/CONVENTIONS.md`.

## Status

**The public-release refactor (`docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md`, Phases 0–7) is functionally complete.** Every Sonnet- and Opus-tier task is done. What's left is entirely human-gated or human-only:

- **P0.1** (`[HUMAN]`, open) — the history/publish strategy decision. Nothing goes public until this is made; `master` sits well ahead of `github/master`, unpushed, pending it.
- **P6.2** (history squash) — downstream of P0.1.
- Replacing `zsh.png` with a current terminal screenshot — the maintainer is doing this themselves (the file is the zsh project logo, correctly used in the README header, not a stale screenshot as the plan assumed).

Highlights of what shipped, for anyone picking this up cold:

- **Secrets/PII scrubbed**, vendored binaries purged, `git`/`gh` mutation removed from shell start (Phase 0).
- **One environment-detection function**, one PATH owner per kind of path, profile manifests replacing 150+ line copy-pasted profile scripts (Phases 1–2).
- **`_zenvs/` renamed to `profiles/`**, `office-macos`/`server-linux` genericised from personal/employer-specific originals (D2, P2.1, P4.5).
- **Startup cut from ~5s to ~550ms** on full profiles, ~56ms on `codex` — the single biggest win was discovering `nvm` was loading twice per shell via a redundant Antidote plugin (`docs/PERFORMANCE.md`).
- **`lib/` consistency swept**: `[[ ]]` over `[ ]`, no shebangs on sourced files, every barrel guarded, colors sourced explicitly everywhere.
- **`packages/zconf`** built from scratch: `doctor`/`scan`/`graph`/`bench`/`normalize`/`new-profile`, 169 vitest tests, wired into CI. Replaced two broken Python normalizer scripts that would have damaged the repo if run.
- **`zupdate` rewritten**: safe staging (`git add -u`, not `git add .`), commitlint-valid messages on every path, a pre-push secret scan, a real rebase-conflict recovery path.
- **Docs and agent rules made zsh-relevant**: `docs/ARCHITECTURE.md`/`PROFILES.md`/`PERFORMANCE.md`/`CONVENTIONS.md` written; `.github/instructions/` stripped of React boilerplate and scoped what's left to `packages/zconf/**`; README rewritten to explain the project rather than just inventory it.

A recurring pattern worth knowing: **most of the real bugs found this refactor were not in the original audit** — they surfaced from building tooling that actually checks the rules (`zconf doctor`'s first run alone found six), or from writing tests that exercise the actual failure path (`zupdate`'s own test suite caught a stranded-commit bug in the rewrite itself). Trust the tools over the plan when they disagree.

Since the refactor: `configs/nvim/` is now a tracked kitchen-sink Neovim config, symlinked from `~/.config/nvim` (real folder lives in the repo so it syncs across machines like the rest of `configs/`). `scripts/setup/` gained a numbered install sequence (`00-install.index.zsh` runs `01`–`06` in order: Homebrew, Antidote, Powerlevel10k+font, fzf, small CLI tools, Neovim+symlink) replacing the old single `scripts/install-zshrc-config-dependencies.zsh` — each numbered script also runs standalone. `configure-git-identity.zsh` stays outside the numbering (a one-time identity setup, not a package install).

### Recent commits

- `fb503a0` fix(nvim): call setup() on plugins that silently no-op without it
- `1196d10` feat(scripts): split install script into numbered setup steps, add nvim install
- `d67962f` feat(zsh): enhance fzf defaults + nvim configuration and custom bindings
- `9e999c7` fix(config): standardize fzf setup across platforms
- `a8dbac3` feat(git): automatically stage pending changes before ai drafting
- `b288808` docs: document ai commit drafts

## Key Decisions

- `oxlint` + `oxfmt` are the linting/formatting tools; `dprint` is not used.
- Commit messages follow Conventional Commits (`commitlint.config.mjs`), enforced locally via husky and in CI (`commitlint` job) — a fork's PR runs the CI check even without the local hook installed.
- `.agents/memory.md` is intentionally gitignored (session-local scratch); `.agents/handoff.md` is tracked and is the durable state snapshot.
- Two git remotes exist: `origin` (Bitbucket) and `github` (`finografic/.zshrc-config`, currently private). `master` tracks `github`.

## Open Questions

**P0.1** (history/publish strategy) is the only open decision — the `[HUMAN]` gate. `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md#decisions-needed-from-you` has the full options (D1) with a recommendation; nothing goes public until the maintainer decides.
