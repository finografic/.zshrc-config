# Project — Handoff

> **How to maintain this file**
> Update after sessions that change architecture, add/remove features, resolve open questions, or shift priorities — not every session.
> — Update only the sections that changed. Keep the total under 150 lines.
> — Write in present tense. No code snippets — describe what exists, not how it works.
> — `.agents/memory.md` = chronological working memory / session log. `.agents/handoff.md` = current project state snapshot. See `docs/process/PROJECT_MEMORY_MODEL.md`.

## Project

Modular Zsh configuration (`zshrc-config`) that adapts to the host: one config tree, multiple environments (home-macos, office-macos, docker-dev, vscode, android, server-linux, codex), with environment-specific aliases, paths, and tooling loaded automatically.

## Architecture

`bootstrap/` runs first (profiling, Antidote plugin manager, plugin loading, compinit, prompt; `typeset -U path PATH` de-dupes `PATH` for the session), then `main.zsh` orchestrates: environment detection (`core/detect.zsh` + `core/env.zsh`) → theme → core zsh options/locale → the profile under `profiles/$ZENV/` → splash screen.

Profiles are **declarative manifests**, not `source` lists. A profile sets `ZENV_PRESET` (`full` / `minimal` / `container` / `none`), `ZENV_MODULES`, `ZENV_FEATURES`, `ZENV_OPT_IN` and calls `zenv-load`; `core/profile.zsh` resolves module names to `lib/` barrels in a canonical order, feature names to `$ZENV_PATH/$ZENV.<name>.zsh`, and opt-ins to `extras/`. Unknown names fail loudly. The `node` module owns the nvm/pnpm boot sequence so the "nvm before `lib/node.zsh`" invariant cannot be got wrong per-profile. `lib/` modules are inert on source (verified by `tests/test-lib-inert.zsh`); side effects live behind named functions a profile opts into.

Node is off the startup path entirely — `packages/node` is deleted; `packages/` is empty awaiting the Phase 5 `zconf` package. `tests/` holds four zsh test files, all run in CI. AI-agent context lives in `AGENTS.md` (entry point, linked from `CLAUDE.md`), `.github/instructions/**` (rule files, currently generic TS/React boilerplate — flagged for a zsh-specific rewrite), `.cursor/rules/`, and this `.agents/` memory pair, plus `docs/todo/ROADMAP.md` for milestone tracking.

## Status

The plan of record is `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md`. It sequences the work needed to take the repo public across Phases 0–8; nine open decisions (D1–D9) at the top of that doc have recommendations, and work proceeds on them unless corrected. Tasks are tagged `[OPUS]` (pause, suggest model switch) or `[HUMAN]` (stop, lay out steps, wait); untagged is Sonnet-tier.

**Phase 0**: done except **P0.1** (history/publish strategy, `[HUMAN]`, still open — the prerequisite before anything goes public). Secrets/PII scrubbed (IPs, a hardcoded SMB password, a deploy alias with a real server IP, tracked `.gitconfig`s, p10k caches), git-config-mutation and `gh auth login` removed from shell start, 66 MB of vendored binaries purged, `LICENSE`/`SECURITY.md`/`CONTRIBUTING.md`/CI added.

**Phase 1**: done. `core/detect.zsh` unifies environment detection (`is-container`, `is-agent-shell`, `is-ide-shell`, `determine-environment`), fixing an unreachable branch and two real bugs (an exported `ZENV` breaking nested-shell detection; a subshell discarding a resolved global) caught by `tests/test-detect.zsh`. Source-time side effects purged from `lib/` (`zclean`, `zdoctor` replace auto-running cleanup/security checks).

**Phase 2**: P2.1 done — `office-macos` genericised to a neutral ~30-line "work Mac" template (`lib/macos/macos.brew.zsh` now holds the Homebrew-prefix detection shared with `home-macos`); `_zenvs/apnaes` renamed to `server-linux` (7 files; `_zenvs/` itself was later renamed to `profiles/` in P4.5), with `chown-no`/`chown-ls`/`chown-apnaes` collapsed into one `chown-to [-R] [--dry-run]`, LSWS moved to an optional `server-linux.lsws.zsh` module (sourced only when `$LSWS_ROOT` exists), and the `edit`/`code` function bugs fixed. The `home-macos` `apnaes`-specific repo aliases now go through the existing `REPO_ALIASES` `.env` pattern instead of being hardcoded; the much larger `finografic`-branded alias block in the same file is untouched (out of scope — flagged for P7.1/P7.3). CI's secret-scan now enforces `apnaes` is gone; `finografic` stays out of the pattern since `@finografic/*` is a legitimate npm dependency scope as well as an org name. P2.2 built the manifest loader described in Architecture above and converted all eight profiles (entry points now 32–58 lines; `main.zsh` shed ~60 lines of unconditional sourcing, leaving `vendor/index.zsh` unused). P2.3 is largely absorbed by that conversion; what remains of it is per-profile content review, including one new finding — `home-linux`'s `hardware` feature probes real hardware at profile load and prints on every shell, which wants testing on an actual Linux desktop before changing.

**Phase 4 performance work (P4.3 + most of P4.4) is done, out of order, ahead of Phase 3** — see `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md#p43--measure-it` for why. `scripts/bench-startup.zsh` provides `--all-profiles`/`--json`/`--save`, a TTY-gated spinner, and streaming per-profile rows; `ZSHRC_PROFILE=1` gives a one-command `zprof` breakdown; CI has a soft-fail startup-budget ratio check. Three real fixes, each measured before and after:

- **Removed the `lukechilds/zsh-nvm` plugin** — nvm was being loaded twice per shell (once by the plugin, once by `vendor/nvm.zsh`). −65% on full profiles.
- **Lazy nvm** — `vendor/nvm.zsh` no longer sources `nvm.sh` at startup; it reads the one-line `alias/default` file and puts that version's `bin/` on `PATH` directly. `nvm.sh` loads only on a real `nvm` call or an `.nvmrc` wanting a _different_ version. 2.5 ms vs 584 ms on the common path — the single biggest win.
- **Splash caching** — `pnpm --version` (192 ms; pnpm is itself a Node program) is now cached on disk keyed by resolved path + mtime; `node --version`/`uname -m`/`hostname` replaced with zsh builtins/`$NVM_BIN` parameter expansion.

Sandbox result, n=10, splash forced on: `codex` 1,340→63 ms (**now meets its 150 ms budget**), `vscode` 3,707→225 ms, full profiles ~5,000→~550–780 ms. **Confirmed on real hardware**: the maintainer re-ran `scripts/bench-startup.zsh --all-profiles -n 20 --save` post-change and `docs/benchmarks/baseline.json` now holds those numbers — `codex` ~56 ms, `home-macos` ~547 ms, matching or beating the sandbox prediction. Full writeup in `docs/benchmarks/README.md`.

One correction made live: the splash was briefly changed to skip nested/non-login shells by default, on a wrong assumption that a splash on typing `zsh` in an existing terminal was waste. The maintainer caught it immediately — typing `zsh` is deliberate and the splash is the expected result. Reverted to on-by-default (`ZSHRC_SPLASH=0` to disable); this is recorded honestly in the docs as "a switch, not a saving."

Remaining in P4.4: `autoload` for cold functions and `zcompile` for the hot path. Judged not worth chasing further — they target eager `lib/` parsing, now a small slice, and the actual remaining budget gap is the ~475 ms splash kept on by choice.

**P4.5 done**: `_zenvs/` → `profiles/` (D2, confirmed by the user, promoted out of "optional"). `git mv`, all `$ZENV_PATH` construction sites updated (`main.zsh`, all 8 profile headers, `lib/widgets.zsh`'s banner lookup, both test files), README/AGENTS.md/CI updated. Zero `_zenvs` references remain outside `docs/todo/` history entries (which narrate the past on purpose). While touching the README, fixed three more drift items found along the way: stale `tools/`/`packages/node` structure-tree lines, a stale "Spinner + PATH deduplication" feature row, and a stale manual-zprof troubleshooting snippet.

**Phase 3 done**: P3.3 consistency sweep (`[[ ]]` over `[ ]` across `lib/`/`core/`/`profiles/*`, shebangs removed from sourced modules, `vendor/index.zsh` deleted, `lib/fzf.zsh`'s raw `\e[` escapes in `android.banner.zsh` replaced) and P3.5 (every `lib/*.zsh` barrel got a `_ZSHRC_<NAME>_LOADED` guard; every leaf module/profile file using `${_c}`-style vars now sources `lib/colors.zsh` explicitly instead of relying on load order). Three real bugs found along the way, none in the original audit: `_ga()`/`_gb()` used `[[ $1 > "" ]]` (string comparison) instead of `[[ -n "$1" ]]`; `lib/fzf.zsh` ran `git clone` unconditionally at source time on Linux whenever `~/.fzf` was missing (moved into `install-fzf()`); `lib/git/git.tags.zsh` hand-rolled its own hardcoded-bold color palette instead of sourcing `lib/colors.zsh` (deleted, now shares the one palette — `_gtag`'s output weight changes slightly as a result, cosmetic only). Deliberately deferred, written up in the TODO doc: `echo`→`print` sweep, confirm-prompt label normalization, `main.zsh` section-number cleanup, CI wiring for the two `normalize-*.py` scripts.

**Phase 5 done**: `packages/zconf`, the maintainer CLI — TypeScript, tsdown, 169 vitest tests, picocolors via a shared `pc` helper, strict tsconfig with `@types/node`. Six commands: `doctor` (lints the load-model contract), `scan` (secrets/PII), `graph` (mermaid, or one profile's resolved load order), `bench` (wraps `scripts/bench-startup.zsh`, diffs the baseline), `normalize` (replaces both Python scripts, now deleted), `new-profile` (scaffolds from templates that already pass `doctor`). A CI job runs tests, typecheck, `doctor` and `scan`; the older grep-based `secret-scan` job stays as a dependency-free backstop. `lib/zconf.zsh` is only a wrapper and refuses cleanly when Node is absent — nothing on the startup path needs it.

`doctor`'s load graph is seeded from profile manifests as well as literal `source` lines, because `zenv-modules` resolves barrels through `${ZENV_MODULE_PATHS[$name]}`; a grep-based graph would call every barrel an orphan. It found six real bugs on its first run, all fixed: an `alias lr="find $(pwd) …"` that expanded at source time (baking the startup directory into the alias permanently), `xcrun` and `which` shell-outs at source time, a missing `function` keyword, a snake_case name, and four hardcoded `~/.zshrc-config` source paths. Porting the Python normalisers surfaced two more: both originals would have damaged the repo if run (one stripping the space in every `function x() {`, the other shoving prose out of multi-line `# NOTE:` blocks in 28 files). The port fixes both and is idempotent.

**Next: Phase 6** (`zupdate` rewrite, `[OPUS]`, stays pure zsh) and **Phase 7** (docs/agent-rules/CI, mostly Sonnet-tier). `docs/ARCHITECTURE.md` from P1.1 is still unwritten, which is what `zconf graph --write` needs as a target.

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

Decisions D1–D9 in `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md#decisions-needed-from-you`. **D2** (`_zenvs/` → `profiles/`) is confirmed and done (P4.5); the rest have a recommendation each and work proceeds on them unless corrected. **D1** (history/publish strategy) is the open `[HUMAN]` gate — nothing goes public until that call is made.
