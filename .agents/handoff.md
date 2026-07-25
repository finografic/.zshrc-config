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

The plan of record is `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md` (the older `PROJECT_ANALYSIS_AND_REFACTOR.md` audit was folded into it and deleted 2026-07-25). It sequences the work needed to take the repo public: Phase 0 (blocking — secrets/PII scrub, git history strategy, drop 70 MB of vendored binaries, stop mutating global git config, add LICENSE/CI), Phase 1 (load-model contract, side-effect purge, single `PATH` owner), Phase 2 (`office-macos` genericised, `apnaes` → `server-linux`, declarative profile manifests), Phases 3–4 (`lib/` consolidation, startup performance budget), Phase 5 (a `zconf` TypeScript toolkit off the hot path), Phases 6–8 (`zupdate` rewrite, docs/agent-rules/CI, optional polish). Nine open decisions (D1–D9) are listed at the top of that doc with recommendations; work proceeds on the stated recommendations unless corrected. The doc tags a minority of tasks `[OPUS]` (pause, suggest model switch) or `[HUMAN]` (stop, lay out steps, wait) — most tasks are Sonnet-tier and proceed automatically.

Phase 0 is done except **P0.1** (history/publish strategy — a `[HUMAN]` gate, still open and a prerequisite before anything goes public). P0.3 removed the git-config-mutation and `gh auth login` side effects from the shell-start path (`scripts/setup/configure-git-identity.zsh` is the manual replacement); P0.4 purged 66 MB of vendored binaries from `tools/` (`scripts/setup/install-tools.zsh` installs them instead); P0.5 added `LICENSE`, `SECURITY.md`, `CONTRIBUTING.md` and `.github/workflows/ci.yml`. P0.2 scrubbed the IPs and PII: the `IP_ADDRESSES` map and the `curl ipinfo.io` call on every shell start are gone (replaced by a lazy `myip`), SSH/deploy/NAS host details now come from `.env`, and a hardcoded SMB password plus a deploy alias carrying a real server IP were found and removed. Tracked `.gitconfig`s, p10k username caches, `package-lock.json` and assorted junk files are untracked.

Node is now entirely off the startup path: P4.1, P4.2 and the `typeset -U path PATH` item from P1.3 were pulled forward, because untracking `packages/node/dist/` broke the two startup `node` calls that depended on it. `packages/node` is deleted; `packages/` is empty awaiting the Phase 5 `zconf` package, and `pnpm-workspace.yaml` is kept for it.

Residual `apnaes` and `finografic` organisational names remain in the tree and are owned by P2.1 (the `server-linux` rename and the `REPO_ALIASES` move) and P7.3 (agent rules) — they are deliberately not yet in the CI `secret-scan` pattern so CI stays green. Phase 1 is next.

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
