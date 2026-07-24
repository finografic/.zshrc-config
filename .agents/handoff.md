# Project — Handoff

> **How to maintain this file**
> Update after sessions that change architecture, add/remove features, resolve open questions, or shift priorities — not every session.
> — Update only the sections that changed. Keep the total under 150 lines.
> — Write in present tense. No code snippets — describe what exists, not how it works.
> — `.agents/memory.md` = chronological working memory / session log. `.agents/handoff.md` = current project state snapshot. See `docs/process/PROJECT_MEMORY_MODEL.md`.

## Project

Modular Zsh configuration (`zshrc-config`) that adapts to the host: one config tree, multiple environments (home-macos, office-macos, docker-dev, vscode, android, apnaes, codex), with environment-specific aliases, paths, and tooling loaded automatically.

## Architecture

`bootstrap/` runs first (profiling, Antidote plugin manager, plugin loading, compinit, prompt), then `main.zsh` orchestrates: environment detection (`core/env.zsh`) → theme → core zsh options/locale → shared `lib/` modules (colors, utils, dev, git, widgets, fzf) → environment-specific profile under `_zenvs/$ZENV/` → splash screen. `packages/node/` holds small TypeScript CLI utilities (spinner, PATH build) compiled via tsdown and invoked from `main.zsh` at shell start. AI-agent context lives in `AGENTS.md` (entry point, linked from `CLAUDE.md`), `.github/instructions/**` (rule files, currently generic TS/React boilerplate — flagged for a zsh-specific rewrite), `.cursor/rules/`, and this `.agents/` memory pair, plus `docs/todo/ROADMAP.md` for milestone tracking.

## Status

A full project audit is complete: `PROJECT_ANALYSIS_AND_REFACTOR.md` (repo root) documents broken/orphaned tooling, dedupe and cleanup targets, an `office-macos` skeleton-reset plan, AI-agent-doc realignment, a `zupdate` rewrite proposal, and optional folder-restructure/TypeScript/git-history work, sequenced into a 6-phase plan. Phase 1 (tooling truth) is now done: real `oxlint` + `oxfmt` configs were added and wired into `lint-staged` via Husky `pre-commit`, with `commitlint` enforcing conventional commit messages via `commit-msg`. This replaces a prior setup where `oxlint`/`dprint` were referenced in `package.json`/`AGENTS.md` but never actually installed or configured. Phases 0 and 2–6 (quick-win cleanup, `office-macos` skeleton, `zupdate` rewrite, agent-doc rewrite, structure/TS decisions, git-history squash) are not yet started.

### Recent commits

- `687f0cb` docs: add project analysis and refactor plan
- `81b5194` build: add oxlint/oxfmt linting and formatting with husky commit hooks
- `08e9b5e` feat(markdown): genx audit used to add Markdown linting (@finografic/md-lint)
- `d3ce364` feat(ai-memory): genx audit used to add AI Memory (roadmap, handoff, session memory)
- `465d3fe` feat(ai-instructions): genx audit used to add AI Instructions (Copilot, Cursor rules)
- `f7362e8` feat(ai-agents): genx audit used to update AI Agents (AGENTS.md + skills)

## Key Decisions

- `oxlint` + `oxfmt` are the linting/formatting tools going forward; `dprint` is not used (no config exists, not treated as active tooling).
- Commit messages must follow Conventional Commits (`commitlint.config.mjs`); the existing `zupdate` auto-message (`updated from: $ZENV`) does not conform and is slated for rewrite (see analysis doc §5).
- `.agents/memory.md` is intentionally gitignored (session-local scratch); `.agents/handoff.md` is tracked and is the durable state snapshot.

## Open Questions

Carried from `PROJECT_ANALYSIS_AND_REFACTOR.md`:

- Delete `packages/node/src/detect-env.ts` (orphaned) or promote it to the single source of truth for environment detection, replacing the zsh implementation in `core/env.zsh`?
- Is the Node startup cost of `spinner.mjs` worth keeping, or should it move to pure zsh so `packages/node`'s build chain can be dropped entirely?
- Flatten `packages/node` → `node/` (monorepo scaffolding is mostly unused), or grow into it?
- When to run the one-time `chore(sync)` git-history squash — after the `zupdate` rewrite makes sync commits identifiable?
