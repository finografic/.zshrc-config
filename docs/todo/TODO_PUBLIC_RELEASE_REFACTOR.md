# TODO — Public Release Refactor

> **Status:** Not started (planned 2026-07-25). Consolidated plan of record for taking
> `zshrc-config` public. Folds in and replaces the earlier `PROJECT_ANALYSIS_AND_REFACTOR.md`
> audit (2026-07-24, since deleted) — its findings are preserved in Appendix A below.

---

## How to read this doc

| Section                                                    | Purpose                                                                                       |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [Decisions](#decisions-needed-from-you)                    | Nine forks in the road. Answer these first — several phases branch on them.                   |
| [Principles](#guiding-principles--the-load-model-contract) | The rules the whole refactor enforces. Everything below is downstream of these.               |
| Phases 0–8                                                 | Sequenced, independently shippable work. Task IDs (`P3.4`) are stable — cite them in commits. |
| [Appendix A](#appendix-a--evidence-log)                    | Raw findings from the 2026-07-25 scan, with file:line.                                        |
| [Appendix B](#appendix-b--target-tree)                     | The end-state directory layout.                                                               |

Phases are ordered by **risk of not doing them**, not by effort. Phase 0 is blocking:
nothing else should be pushed to a public remote until it is done.

**Before dispatching any agent, read [Model routing protocol](#model-routing-protocol) below — some tasks are tagged to pause and hand back for a manual model switch.**

---

## Model routing protocol

This plan is tiered by model. **Most tasks are Sonnet-tier (the default — no marker):**
mechanical, spec-driven transforms with explicit `file:line` targets. A minority are
tagged for a stronger model or for human sign-off, with a callout directly under the task
heading.

| Tag           | Meaning                                                         | Agent behavior on reaching it                                                                                                                                                                                                     |
| ------------- | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| _(none)_      | **Sonnet-tier.** Mechanical, spec-driven.                       | Proceed.                                                                                                                                                                                                                          |
| **`[OPUS]`**  | Design, correctness-sensitive, or net-new authoring.            | **PAUSE before starting.** Do not begin the task. Post exactly: `MODEL SWITCH SUGGESTED -> Opus for <task id>: <one-line reason>`, then stop and wait. Resume only after the user confirms the switch or replies `proceed as-is`. |
| **`[HUMAN]`** | Irreversible or safety-critical (git history, force-push, PII). | **STOP and hand back.** Lay out the exact steps, execute nothing, and wait for an explicit go.                                                                                                                                    |

**Why pause, not self-switch:** an agent cannot change its own model mid-session. The
switch is manual — in Claude Code, `/model opus` or a fresh session; in Cursor, the model
picker. The tag exists so a fast model never silently executes a task that wanted a
stronger one. When a run crosses back into unmarked tasks, suggest switching _down_ to
Sonnet to save cost.

**Batching:** contiguous `[OPUS]` tasks in a phase belong in one Opus session — pause once
at the first, switch, clear the whole run, then switch back. Don't ping-pong per checkbox.

**Greppable:** `grep -n '\[OPUS\]\|\[HUMAN\]' TODO_PUBLIC_RELEASE_REFACTOR.md` lists every
gate and its line.

---

## Decisions needed from you

Each row has a recommendation. Strike through or edit as you decide, then the phases below
become unambiguous.

| #     | Decision                                                                                             | Options                                                                                              | Recommendation                                                                                                                                                                                                                                  |
| ----- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D1    | **How to publish given history is already on GitHub**                                                | (a) fresh public repo, clean history; (b) `git-filter-repo` + force-push existing; (c) publish as-is | **(a)** — see [P0.1](#p01--decide-and-execute-the-history-strategy). Force-pushing does not reliably remove blobs from GitHub, and 1,224 commits of `updated from: home-macos` add nothing for readers.                                         |
| D2 ✅ | **`_zenvs/` naming**                                                                                 | keep `_zenvs/`; ~~rename to `profiles/`~~                                                            | **`profiles/` — CONFIRMED by the user 2026-07-26, no longer optional.** Self-documenting for outsiders; keep `$ZENV` as the variable name so churn is limited to path strings. Scheduled as [P4.5](#p45--_zenvs--profiles-rename-d2-confirmed). |
| D3    | **Profile loading model**                                                                            | keep per-profile hand-rolled `source` lists; move to a declarative manifest                          | **Manifest** ([P2.2](#p22--declarative-profile-manifests)) — the eight profiles are ~80% duplicate boilerplate today.                                                                                                                           |
| D4    | **Vendored binaries (`tools/`, 70 MB)**                                                              | keep; keep only what's used; remove all + installer script                                           | **Remove all + installer** ([P0.4](#p04--purge-vendored-third-party-binaries)) — 13 of 15 are referenced nowhere, and redistributing them publicly is a licensing question you don't need.                                                      |
| D5    | **Node on the startup path**                                                                         | keep `spinner.mjs` + `build-path.mjs`; remove both                                                   | **Remove both** ([P4.1](#p41--remove-node-from-the-startup-path)) — two process spawns per shell for a fake progress delay and a job `typeset -U path` does natively.                                                                           |
| D6    | **Where TypeScript lives**                                                                           | nowhere; startup helpers; a deliberate `zconf` dev toolkit                                           | **`zconf` toolkit** ([Phase 5](#phase-5--typescript-where-it-actually-earns-its-place)) — off the hot path, genuinely awkward in zsh, and it's the part that makes this repo interesting publicly.                                              |
| D7    | **Colors: explicit or implicit source**                                                              | implicit (today); explicit `source` per file; **guarded** explicit                                   | **Guarded explicit** ([P3.5](#p35--colors-guarded-explicit-sourcing)) — you get the explicitness with ~zero cost. Answers your open question.                                                                                                   |
| D8    | **Source-time side effects** (`clean.zsh` auto-run, launchd checks, firewall check, `gh auth login`) | keep; gate behind flags; remove from load path entirely                                              | **Remove from load path** ([P1.2](#p12--purge-source-time-side-effects)) — becomes `zclean`, `zdoctor`. A config that mutates your machine on every shell is the #1 thing that scares people off a public dotfiles repo.                        |
| D9    | **IP-based environment detection**                                                                   | keep; remove                                                                                         | **Remove** ([P0.2](#p02--scrub-secrets-and-pii-from-the-working-tree)) — it hardcodes your home IP, breaks on any DHCP change, and `.env` flags already cover every real case.                                                                  |

---

## Guiding principles — the load-model contract

These five rules are the spine of the refactor. Most individual tasks below are just
"make file X obey rule N".

### 1. Layers, and what each is allowed to do

| Layer                                | Role                                                                          | May it cause side effects?                                        |
| ------------------------------------ | ----------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `bootstrap/`                         | Ordered early init — profiling, Antidote, plugins, compinit, prompt           | **Yes** — that is its job. Order is load-bearing.                 |
| `core/`                              | zsh-level settings: options, history, keybindings, locale, env detection      | Settings only. No user-facing output, no network, no disk writes. |
| `vendor/`                            | Third-party runtime init and `PATH` (`nvm`, `pnpm`)                           | Only `PATH`/env exports for the tool it owns.                     |
| `lib/<domain>.zsh` + `lib/<domain>/` | Barrel + leaf modules. **Definitions only** — functions, aliases, completions | **No.** Sourcing must be inert.                                   |
| `profiles/<name>/`                   | Host-specific paths, aliases, banner, opt-in features                         | **Yes, and only here** (plus `main.zsh`).                         |
| `extras/`                            | Opt-in: music, hardware, examples. Never auto-sourced                         | N/A — not on the load path.                                       |

> **The rule that matters:** sourcing anything under `lib/` must not run anything.
> If a module does work today, that work becomes a named function, and the _profile_
> decides whether to call it. This is what makes the config safe for a stranger to try.

### 2. One source of truth per fact

Environment detection, `PATH` ownership, colors, and Node boot each live in exactly one
place. Duplicates get deleted, not synchronised.

### 3. Profiles declare, the loader resolves

A profile says _what it wants_ (`ZENV_MODULES`, `ZENV_FEATURES`); a single loader in `core/`
figures out _how_. Adding a host becomes a 15-line file, not a 160-line copy-paste.

### 4. Startup has a budget, and it is measured

Full interactive shell **< 400 ms**, minimal profiles (vscode/codex/docker) **< 150 ms**,
enforced by a benchmark script and asserted in CI. No change lands that regresses it
without a note saying why.

### 5. Public means portable

No hardcoded usernames, emails, IPs, machine names, or absolute `/Users/justin` paths on
the load path. Anything personal comes from `.env` or a gitignored local override.

---

## Phase 0 — Publish safety

**Blocking. Nothing in this repo should go public until every box here is ticked.**

The GitHub remote (`git@github.com:finografic/.zshrc-config.git`) already has `master`
pushed. Everything below is therefore already exposed to anyone with access to that remote,
and will be world-readable the moment it flips public.

### P0.1 — Decide and execute the history strategy

> **`[HUMAN]`** — Irreversible (fresh public repo, or `git-filter-repo` + force-push). Do **not** execute: lay out the exact commands and which machines need re-cloning, then STOP and wait for the user to run or explicitly authorize them. See [Model routing protocol](#model-routing-protocol).

- [ ] Confirm the current visibility of `github.com/finografic/.zshrc-config` (private, hopefully).
- [ ] Tag the current state on the private remote as an archive: `git tag archive/pre-public-2026-07-25 && git push origin --tags` (Bitbucket = archive of record).
- [ ] **Recommended (D1a):** create a _new_ public GitHub repo and seed it with a clean, single-commit (or hand-curated) history from a scrubbed working tree. Keep Bitbucket + the existing GitHub repo private forever.
  - Rationale: `git-filter-repo` + force-push leaves unreachable blobs reachable by SHA on GitHub until support garbage-collects them. A fresh repo has no such caveat, and it drops 33 MB of `.git` plus 70 MB of binaries in one move.
  - Cost: you lose public commit history. Given 570 of 1,224 commits are `updated from: *` / `Commit all changes`, that history has near-zero informational value to a reader.
- [ ] If you choose (D1b) instead: run `git-filter-repo` for the IPs, emails, `tools/bin-*`, and tracked p10k caches; force-push; then re-clone on _every_ machine before the next `zupdate` (a stale clone will fight the rewrite badly).
- [ ] Either way: write down which machines need re-cloning and do them in one sitting.

### P0.2 — Scrub secrets and PII from the working tree

> **`[OPUS]`** — High-stakes, easy to under-scrub. PAUSE and suggest switching to Opus before starting. Note: after the sweep, the `zconf scan` / CI regex — not the model — is the real backstop; a human confirms a clean grep before anything is pushed. See [Model routing protocol](#model-routing-protocol).

Independent of D1 — the working tree must be clean regardless.

- [x] `core/env.zsh:51-55` — delete the `IP_ADDRESSES` map (real home / office / server IPv4 addresses).
- [x] `core/env.zsh:71` — remove the `$IP == ${IP_ADDRESSES[APNAES]}` detection branch (D9). `.env` flags are sufficient.
- [x] `core/env.zsh:44-48` — drop the unconditional `curl -s ipinfo.io/ip` fallback. It is a **network call on every shell start** that also leaks your IP to a third party. Make `$IP` lazy: a `myip` function, called on demand. (Added `myip` / `myip --public`; the two `$IP` consumers — the `ip` alias in `lib/utils.zsh`, which baked the address in at _definition_ time, and the splash footer — now call it at runtime.)
- [x] `packages/node/src/types.ts:32` + `src/detect-env.ts` + all of `packages/node/dist/` — same IPs, plus committed build output. Deleted wholesale in [P4.2](#p42--delete-orphaned-node-utilities). (Pulled forward: removing `dist/` broke `main.zsh`'s two node calls, so [P4.1](#p41--remove-node-from-the-startup-path) and the rest of P4.2 were completed in the same pass.)
- [x] `tools/bin-arm64/install-binaries.sh:28` and `tools/bin-x86_64/install-binaries.sh:28` — same server IP. Removed with [P0.4](#p04--purge-vendored-third-party-binaries).
- [x] `_zenvs/office-macos/office-macos.zsh:101-102` — remove `git config --global user.name/user.email`. See [P0.3](#p03--stop-mutating-global-git-config-and-authenticating-on-shell-start).
- [x] `_zenvs/home-linux/home-linux.dev.zsh:51` and `lib/git/git.core.zsh:92` — same pattern with the personal address. Remove; identity is a machine-setup step, not a shell-start step.
- [x] `_zenvs/home-macos/home-macos.dev.zsh:219` — the `ssh` aliases. Host/user/port/key now come from `.env` (`SERVER_SSH_HOST`, `SERVER_SSH_USER`, `SERVER_SSH_PORT`, `SERVER_SSH_KEY`), documented in `.env.example`. The `.pub`-as-identity-file bug is fixed (`SERVER_SSH_KEY` is the private key). The second host in `home-linux.dev.zsh:17` got the same treatment via `TUNNEL_SSH_*`.
- [x] Root `.gitconfig` and `configs/.gitconfig` — root one deleted outright (it was a copy of this repo's `.git/config`, only used by the office `cp` removed in P0.3); `configs/.gitconfig` → `configs/gitconfig.example` with placeholders.
- [x] `themes/p10k/$HOME.cache/p10k-*justin.rankin*` (6 tracked files, incl. `.zwc`) — untracked, and `.gitignore` now covers `*.zwc` + `themes/p10k/**/*.cache/`.
- [x] `configs/.zshrc.OFFICE:1-5` — deleted (confirmed it carried `CYPRESS_SBS_USER_PASSWORD`, `CYPRESS_CF_ACCESS_CLIENT_SECRET`, `AWS_CONFIG_FILE`). The remaining `configs/.zshrc.{HOME,SERVER,DOCKER}` are [P1.5](#p15--collapse-the-configs-reference-zshrc-files).
- [x] Hardcoded absolute home paths made portable: `home-macos.paths.zsh:9` (bun), `home-linux.zsh:21` (konsole), `home-macos.zsh:53` (pm2 comment), and the djay LaunchAgent plist + its inline copy, which are templates and now use a `__HOME__` placeholder (launchd cannot expand `$HOME`).
- [x] `_zenvs/docker-dev/configs/` deleted — `.zshrc-docker`, `.zshrc-docker-V2` (carried a `/Users/justin.rankin` path), and the stray `z` file. Also a [P1.5](#p15--collapse-the-configs-reference-zshrc-files) item.
- [x] Untrack `Icon\r`, `scripts/Icon\r`, `scripts/Icon?-_DJ-BAG`, `.main.zsh.swp`, `package-lock.json` (repo uses pnpm); all now gitignored. `.DS_Store` was already untracked and ignored.
- [ ] **Grep sweep — partially clear.** IPv4 literals: **zero** remain in tracked non-doc files. Emails, `@sage`, `hostinger`, `justin.rankin`: **zero**. Still outstanding, each owned by a later phase and each an _organisational name_ rather than a secret:
  - `apnaes` throughout `_zenvs/apnaes/**`, `README.md`, `core/env.zsh` — resolved by the `server-linux` rename ([P2.1](#p21--the-two-renames-you-asked-for)).
  - `finografic` repo-alias values in `_zenvs/home-macos/home-macos.aliases.zsh` (incl. `cv-justin-rankin`) — moved into `.env` via the `REPO_ALIASES` registry ([P2.1](#p21--the-two-renames-you-asked-for), final bullet).
  - `bitbucket.org:justin-rankin/…` and the `$REPOS_FINO` note in `AGENTS.md:110-111` — [P7.3](#p73--agent-rules-made-relevant).
  - `finograficKeyword*` example identifiers in `.github/instructions/naming/variable-naming.instructions.md` — [P7.3](#p73--agent-rules-made-relevant).
  - `@finografic/*` npm package names (`.npmrc`, `package.json`, `.markdownlint.jsonc`, `.vscode/settings.json`) — **intentional and correct**; these are real published dependencies, not PII.
  - **Phase 0 exit criteria is therefore not met until P2.1 and P7.3 land.** CI's `secret-scan` job enforces this and currently fails by design.

### P0.3 — Stop mutating global git config and authenticating on shell start

Three separate footguns, all on the load path:

- [x] `_zenvs/office-macos/office-macos.zsh:90-99` — `cp "$ZSHRC_ROOT/.gitconfig" "$ZSHRC_ROOT/.git/config"` **overwrites this repo's git config, including its remotes, on every office shell.** This is the single most destructive line in the repo. Delete it.
- [x] `git config --global …` calls in three profiles — delete. Provide `scripts/setup/configure-git-identity.zsh`, run once, interactively.
- [x] `main.zsh:153` — `gh auth login --with-token < <(printf '%s' "$NPM_TOKEN")` runs on **every interactive shell**: it spawns `gh`, passes a token through a process substitution, and silently swallows failures with `2>/dev/null`. Delete. Authenticate once, manually.
- [x] `core/env.zsh:17` — `awk`-parsing `NPM_TOKEN` out of `.env` after already sourcing `.env` is redundant; the `source` already set it. Remove the `awk` call (and the duplicate in `lib/node/pnpm.zsh:40`).

### P0.4 — Purge vendored third-party binaries

`tools/` is 70 MB, of which **~66 MB is referenced nowhere in the codebase**.

| Binary                                             | Size    | Referenced?                                         |
| -------------------------------------------------- | ------- | --------------------------------------------------- |
| `bin-arm64/rclone`                                 | 49 MB   | No                                                  |
| `batcat` (×2)                                      | 8.4 MB  | No (only a commented-out alias in `lib/common.zsh`) |
| `SymbolsNerdFontMono-Regular.ttf` (×2)             | 4 MB    | No                                                  |
| `exa` (×2)                                         | 2.3 MB  | No                                                  |
| `fastfetch` + `fastfetch-BAK` (×4)                 | 4.7 MB  | `fastfetch` only, `lib/widgets.zsh:104`             |
| `neofetch` (×2)                                    | 672 KB  | Yes, `lib/widgets.zsh:94`                           |
| `lsof`, `df`, `pfetch`, `nerdfetch`, `ollama-test` | ~800 KB | No                                                  |

- [x] Delete `tools/bin-arm64/` and `tools/bin-x86_64/` from tracking (D4).
- [x] Replace with `scripts/setup/install-tools.zsh` — Homebrew on macOS, apt/pacman fallback on Linux, for `fastfetch`, `bat`, `eza`, `rclone`, `fzf`, and the Nerd Font.
- [x] `lib/widgets.zsh:88-110` — simplify to "use `fastfetch` if on `PATH`, else `neofetch` if on `PATH`, else print a plain banner". Drop the `$ZSHRC_ROOT/tools/bin-$OS_ARCH/` fallbacks.
- [x] Keep `tools/bin-*/INSTALLS.md` + `OLLAMA.md` content by folding the useful notes into `docs/`, then delete the directories. (`OLLAMA.md` folded into `docs/OLLAMA.md`, scrubbed of the `/Users/justin` path; `INSTALLS.md` was stale/broken placeholders — superseded by `scripts/setup/install-tools.zsh` instead of transcribed.)

> Beyond size: shipping other people's compiled macOS binaries in a public repo means
> shipping their licences and their CVEs, and unsigned binaries from a GitHub clone will
> trip Gatekeeper on anyone else's Mac anyway.

### P0.5 — Legal and repo furniture

- [x] Add `LICENSE` — MIT is the norm for dotfiles and imposes nothing on you.
- [x] Add `SECURITY.md` (one paragraph: this is a personal config, report issues via issues).
- [x] Add `CONTRIBUTING.md` — short: conventional commits, run `pnpm lint`, PRs welcome for portability fixes.
- [x] `package.json` — add `"license"`, `"author"`, `"private": true`. (`"repository"` deliberately omitted — the public repo URL is undecided pending [P0.1](#p01--decide-and-execute-the-history-strategy), a `[HUMAN]` gate.)
- [x] Add `.github/workflows/ci.yml` with the _cheap_ guards now, expanded in [P7.4](#p74--ci): `zsh -n` syntax check on every tracked `.zsh` file, a secret/PII regex scan, `oxlint`, `oxfmt --check`, `md-lint`. (`shfmt --diff` and PR-title `commitlint` deferred to P7.4 — `shfmt` isn't installed in CI yet and commitlint already runs locally via husky.)

**Exit criteria:** the PII grep sweep returns only placeholders; CI is green; `LICENSE` exists;
`du -sh` of the working tree is single-digit MB.

---

## Phase 1 — Load-model contract

Make the repo obey [the principles](#guiding-principles--the-load-model-contract). This is
the highest-leverage structural phase and everything after it gets easier.

### P1.1 — Write the contract down

- [x] Add `docs/ARCHITECTURE.md`: the layer table, the side-effect rule, `PATH` ownership, and a mermaid load-order diagram (`.zshrc` → `bootstrap/*` → `main.zsh` → `core/env` → `lib/*` → `profiles/$ZENV` → splash). — A small hand-drawn conceptual diagram leads the doc (readable — 12 nodes); the full 118-node/180-edge graph from `zconf graph --write --grouped` sits at the bottom as ground truth, clearly labelled as the literal complement to the concept above it, not a replacement for it.
- [x] Add "Architecture in 60 seconds" to `AGENTS.md` pointing at it.
- [x] Auto-generate the diagram from the real source graph in [P5.2](#p52--zconf-commands) so it cannot drift. — Done via the `<!-- zconf:graph:start/end -->` markers `zconf graph --write` targets; re-running it after a structural change is a documented one-liner (`pnpm zconf graph --write --grouped`).

### P1.2 — Purge source-time side effects

> **`[OPUS]`** — Load-order-sensitive: each side effect becomes a named function a profile opts into, without changing boot behavior. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Every item is "wrap in a function; let a profile or the user call it" (D8):

- [x] `lib/clean.zsh:20-24` — **auto-runs `clean-downloads`, `clean-browsers`, `clean-caches-npm` on every full shell.** Deleting files on shell start is indefensible in a public repo. Replace with a `zclean [--all|--downloads|--browsers|--node] [--dry-run]` entry point. — Done. `--dry-run` is real, not cosmetic: a shared `clean-exec` helper wraps every destructive call and prints instead of executing. Two latent bugs fixed while in there: `clean-browsers` hardcoded one machine's random Firefox profile ID (now globbed, and the keep-list is overridable via `FIREFOX_KEEP_ORIGINS`), and it `rm -fr`'d the storage dir before re-globbing. The opt-in `ZSHRC_AUTOCLEAN=1` daily-stamp variant was **not** implemented — deliberate; ask for it if you want it.
- [x] `_zenvs/home-macos/home-macos.zsh` + `office-macos.zsh` — the djay / djay-sync LaunchAgent blocks run `launchctl list | grep` (×2) and can `launchctl load` on every shell. Move to `extras/music/`, expose as `djay-services-check`, and call it from nothing by default. — Done: `extras/music/djay-services.zsh`. Verified it is _not_ defined in a normal shell.
- [x] `office-macos.zsh:113-118` — the firewall `socketfilterfw --getglobalstate` shell-out. Move into `zdoctor`. — Done: new `lib/doctor.zsh` provides `zdoctor` (machine health: tool presence + firewall state), sourced from `main.zsh`. Distinct from the future `zconf doctor`, which lints the repo.
- [x] `update-ghostty-config` is invoked at profile load in both macOS profiles. Make it explicit or gate it on the config file actually being stale. — Gated on staleness via the `-nt` **builtin** (no subprocess on the no-op path, unlike a `diff` shell-out). `--force` added for the `_config` helper.
- [x] `main.zsh:147-150` — `extras/music/djay_icloud_sync.zsh` and `scripts/docker-cleanup.zsh` are sourced for **all** environments. Per the layer table, `extras/` is opt-in: move to `profiles/home-macos/`.
- [x] Sweep for remaining top-level work: any tracked `.zsh` under `lib/` whose body has a bare command at column 0 that isn't a `source`, `export`, `alias`, `typeset`, `autoload`, or `zstyle`. Automate this as a `zconf doctor` lint ([P5.2](#p52--zconf-commands)) so it stays fixed. — Swept. Found and fixed:
  - `lib/dev.jest.zsh` ran **`jest --clearCache` on source** (spawning jest on every home-macos shell). Deleted, per [P3.1](#p31--delete-orphans).
  - `lib/mongodb.zsh` called `mverSet` on source. Deleted (orphan).
  - `lib/k.plugin.zsh` — vendored `k`, already loaded via Antidote. Deleted, along with its `.editorconfig` shfmt exemption.
  - `lib/template-tool/` — deleted outright. The "FINAL" script was one-off merge-conflict triage from a past template sync (hardcoded `TEST_DATE="2025-09-15"`, reads `MERGE_HEAD`); nothing reusable to extract, so its `README.tools.md` is dropped from the [P7.2](#p72--docs-set) fold-in list too.
  - `lib/node/nvm-autoload.zsh` registered its `chpwd` hook **and** ran an initial `load-nvmrc` at source time. Both now live in `nvm-autoload-init`, called by `main.zsh` and the three profiles that boot node themselves. The load-order invariant this depends on is [P2.2](#p22--declarative-profile-manifests)'s job to encode.
  - Untracked `plugins/.zsh_plugins.generated.{linux,macos}.zsh` (generated output).

### P1.3 — Single owner for `PATH`

- [ ] Document the rule in `docs/ARCHITECTURE.md`: `vendor/*` owns tool paths, `lib/paths/*` owns OS paths, `profiles/*/…paths.zsh` owns host paths. Nothing else appends.
- [x] Add `typeset -U path PATH` **once**, early in `bootstrap/index.zsh`. This is what `main.zsh:115` already claims exists and what `build-path.mjs` was emulating. (Done with [P4.1](#p41--remove-node-from-the-startup-path).)
- [x] Remove ad-hoc appends from the wrong layers — done in [P2.2](#p22--declarative-profile-manifests): `main.zsh`'s homebrew coreutils/`hs` appends moved to `lib/paths/paths.macos.zsh` (the OS-paths owner), and its generic `$HOME/bin:$HOME/.local/bin:/usr/local/bin` append went with the step-12 block the manifest absorbed. The office Python 3.11 framework path and the `gen-test-summary`/`gen-todo-coverage` appends were deleted with the profile in [P2.1](#p21--the-two-renames-you-asked-for). While in `paths.macos.zsh`, also fixed a `/opt/homebrew/binnpm` typo and removed `$(which curl)` / `$(which python3)` — the same append-a-file-not-a-directory bug as the server profile, costing two subprocesses per shell to do nothing. (Original targets: `main.zsh:100-101`, `main.zsh:116`, `office-macos.zsh:11`, `:56-57`.)
- [x] `_zenvs/apnaes/apnaes.paths.zsh:19` — `export PATH=$PATH:$(which curl)` appends a _file_ path, not a directory. Delete. — Done with [P2.1](#p21--the-two-renames-you-asked-for) (now `_zenvs/server-linux/server-linux.paths.zsh`), which rewrote the file anyway.
- [ ] Delete `lib/paths.zsh:14-16` `flatten-path` (legacy Node call) once [P4.1](#p41--remove-node-from-the-startup-path) lands.

### P1.4 — Fix the environment-detection logic

> **`[OPUS]`** — Subtle correctness (unreachable branches, unified container/agent detection, explicit fallback semantics). PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

- [x] `core/env.zsh:69` — `elif [[ $IS_OFFICE == true || $IS_DOCKER == true ]]` is **unreachable for `IS_OFFICE`**. — Fixed; container detection is now its own branch above the flags, and a regression test asserts `IS_OFFICE` reaches `office-macos`.
- [x] Docker detection is inconsistent: `bootstrap/index.zsh:24` checks `/.dockerenv`, `$IN_DOCKER`, `$DOCKER_CONTAINER`, while `core/env.zsh` relies on `$IS_DOCKER`. Unify into one `is-container` helper used by both. — Done; `bootstrap/02-plugins.zsh` had a third copy, now also using it. Also covers Podman's `/run/.containerenv`, and uses only builtin tests (no subprocess on the load path).
- [x] Codex detection is duplicated verbatim in `bootstrap/index.zsh:10` and `main.zsh:38`. Extract to `core/env.zsh` as `is-agent-shell`. — Done, but the helpers live in **`core/detect.zsh`, not `core/env.zsh`**: `bootstrap/` runs before `core/env.zsh` is sourced, so they could not live there. `core/detect.zsh` is guarded, inert, and safe to source from both. `is-ide-shell` was extracted at the same time (the VS Code check was a fourth inline condition).
- [x] Quote and default all the flag tests (`[[ ${IS_HOME:-false} == true ]]`).
- [x] Move the whole detection block behind a single function with a documented precedence order, and make the fallback explicit. — Precedence is documented in the function header and asserted by `tests/test-detect.zsh` (22 cases, wired into CI). Fallback is now OS-based (`macOS` → home-macos, `Android` → android, anything else → home-linux) and records `$ZENV_RESOLVED_BY=fallback`. **A truly generic profile does not exist yet** — creating one is [P2.2](#p22--declarative-profile-manifests)/[P2.3](#p23--profile-inventory-pass) work, since it should be a preset. Surfacing "you have no `.env` flags set" to the user is deliberately _not_ done here: `core/` may not write to the terminal, so that belongs to the splash.
- [x] **Two bugs found while testing, not in the original audit:**
  - The override branch originally read `$ZENV` itself. Since `ZENV` is _exported_, every nested shell would inherit its parent's answer — a VS Code terminal opened from a normal shell would never resolve to `vscode`. The override now reads a dedicated **`ZENV_FORCE`**, and a test asserts an inherited `ZENV` does not pin a nested shell.
  - `determine-environment` was called as `export ZENV=$(determine-environment)`, so any global it set (`ZENV_RESOLVED_BY`) was discarded with the subshell. It now sets `ZENV`/`ZENV_RESOLVED_BY` directly and `main.zsh` exports afterwards.
- [x] Removed a second source of truth: `themes/default.theme.zsh:6` re-ran `determine-environment` and re-exported `ZENV`. `main.zsh` is now the only resolver. Profile-specific env that used to be set _inside_ the detection branches (`OS_NAME` for the server, `STORAGE_ROOT`/`PATH_ZSHRC` for Android) moved to `apply-environment-env`, called once after `$ZENV` is known.

### P1.5 — Collapse the `configs/` reference zshrc files

`configs/` holds five near-duplicate reference `.zshrc` files (`.HOME`, `.OFFICE`, `.SERVER`,
`.DOCKER`, `.zshrc-docker-orig`) plus a root `.zshrc` template, plus two more under
`_zenvs/docker-dev/configs/`. Eight copies of a three-line file.

- [ ] Keep exactly one: `.zshrc` at the repo root, as the reference template (already the documented convention).
- [ ] Delete `configs/.zshrc.{HOME,SERVER,DOCKER}`, `configs/.zshrc-docker-orig`. (`configs/.zshrc.OFFICE` and all of `_zenvs/docker-dev/configs/` — incl. the stray `z` file — already deleted in [P0.2](#p02--scrub-secrets-and-pii-from-the-working-tree).)
- [ ] Keep `configs/{ghostty.config,kitty.conf,.vimrc,plug.vim}` — those are real reference configs. Consolidate `.vimrc.V1`/`.vimrc.V2` to one and drop `ghostty.config.office` if it differs only in font size.
- [x] Delete `_zenvs/docker-dev/configs/z` (stray file).

**Exit criteria:** `source`-ing any `lib/**.zsh` in a bare `zsh -f` produces no output and
touches no files; `docs/ARCHITECTURE.md` matches reality.

---

## Phase 2 — Profile system

### P2.1 — The two renames you asked for

> **Done 2026-07-26.** `_zenvs/` stays `_zenvs/` for now — the `profiles/` rename is D2/[Phase 8](#phase-8--optional-polish), a separate decision, and this task didn't need it. Path below is `_zenvs/server-linux/`, not `profiles/server-linux/`.

**`office-macos` → generic office profile** (515 lines across 8 files → **118 lines across 5**):

- [x] Remove all employer-specific content: the `SBS-` branch-prefix helper `_gb` (`office-macos.zsh:66-76`), `parse-coverage` / `gen-test-summary` / `gen-todo-coverage` PATH hacks, `office-macos.dev.jest.zsh`, `parse-test-coverage.zsh`, the Cypress/CF secrets in `configs/.zshrc.OFFICE`, and everything in [P0.3](#p03--stop-mutating-global-git-config-and-authenticating-on-shell-start). Also deleted as dead + personal (not called out by name here, but same rationale): `office-macos.backups.zsh` (hardcoded a Sage OneDrive path, sourced nowhere) and `office-macos.hardware.zsh` (Spanish-keyboard locale settings, its `source` line was already commented out).
- [x] Replace the banner with a plain `OFFICE` figlet (`office-macos.banner.zsh`).
- [x] Strip the commented-out dead blocks: PM2/launchd, Docker Desktop autostart, `lsof` security scan, iTerm2 integration, Loupedeck paths.
- [x] Keep the genuinely reusable bones: dynamic Homebrew prefix detection … should be **promoted to a shared helper** used by every macOS profile. — New `lib/macos/macos.brew.zsh` (`macos-brew-shellenv`), used by both `home-macos.zsh` and `office-macos.zsh`.
- [x] End state: a populated-but-neutral "work Mac" profile … a few example aliases, a `paths.zsh` stub, a `TODO: populate per employer` marker. — `office-macos.zsh` is 32 lines; `office-macos.paths.zsh` is a new stub, not yet sourced.
- [x] **Bugs fixed while genericising, not in the original audit**: `confirm()` in `office-macos.dev.zsh` was dead code that just echoed its own input back — rewritten to actually return a yes/no result. Two `[[ $1 > "" ]]` non-empty-test bugs (in `confirm()`'s sibling `commit()`, matching the audit's [P3.3](#p33--consistency-sweep) finding) fixed to `[[ -n "$1" ]]`.

**`apnaes` → `server-linux`** (307 lines across 8 files → **~230 lines across 6**, one of which is new):

- [x] `git mv _zenvs/apnaes _zenvs/server-linux`, rename all files, delete `apnaes.paths-V1.zsh` and `apnaes.paths-V2.zsh`. Also deleted `apnaes.hardware.zsh` (same dead-and-personal reasoning as office's copy — its `source` line was commented out, and keyboard locale settings make no sense for a headless server).
- [x] Genericise: `REPOS="/home/apnaes/repos"` → `${SERVER_REPOS:-$HOME/repos}`; `chown-apnaes` → drop; keep `chown-no` / `chown-ls` but rewrite them as one `chown-to <user>:<group>` with `--dry-run`. — Done as `chown-to [-R] [--dry-run] <user>[:<group>] <path>`, parsed with a proper flag loop rather than positional juggling. `-R` was optional in the original two functions; preserved rather than forced on.
- [x] **Keep LSWS as an optional module** … `server-linux.lsws.zsh`, sourced only when `/usr/local/lsws` exists … `logs [std|acc|err] [--clear]`, `vh`/`lsws`/`ws`, `lu`. Parameterise as `${LSWS_ROOT:-/usr/local/lsws}`. — Done exactly as specified; verified standalone (sourcing it directly defines all four, and the nav aliases correctly interpolate `$LSWS_ROOT`).
- [x] Keep the PM2-under-`lsadm` wrappers but gate them on `command -v pm2`. — Done; moved into the LSWS module alongside `lu` (same `lsadm`-user context). Verified both branches: absent when `pm2` isn't on `PATH`, present when it is.
- [x] Replace the `APNAES` ASCII banner with `SERVER`, and show hostname + distro + uptime. — Done, reading `/etc/os-release` for distro with a fallback.
- [x] Fix `apnaes.zsh:9` — `edit()`/`code()` quoting and `eval` bugs. — `edit() { "$EDITOR" "$@"; }`; `code() { jmate "$@"; }` (no `eval`, and no dependency on `which` succeeding).
- [x] `apnaes.aliases.zsh:2-3` — `logout`/`lo` SSH escape-sequence aliases. — Deleted, documented as a manual keystroke instead (they cannot work as shell aliases).
- [x] **Bug found while rewriting, not in the original audit**: `alias lr1="find $(pwd) -mtime -1 …"` baked in `$(pwd)` at shell-**start** time — always the login directory, never wherever you'd actually `cd`'d to. Now a function using `$PWD`, evaluated at call time.
- [x] Sweep the ghost references: `core/env.zsh`, `core/detect.zsh` (didn't exist at audit time; created in [P1.4](#p14--fix-the-environment-detection-logic)), `lib/node/nvm-autoload.zsh`, `lib/widgets.zsh`, `vendor/nvm.zsh`, `README.md`. `packages/node` no longer exists ([P4.2](#p42--delete-orphaned-node-utilities)). `.agents/handoff.md` rewritten wholesale, not swept. **Zero `apnaes` references remain in tracked code** — added to the CI `secret-scan` pattern to keep it that way (`.agents/**` and `docs/todo/**` excluded, since they narrate history).
- [x] **Do not** touch the `home-macos` client-side shortcuts (`REPOS_APNAES`, `alias apnaes=…`, `alias mono=…`) … Move their values into `.env` via the existing `REPO_ALIASES` registry pattern. — Done for the `apnaes`-specific four (`REPOS_APNAES`, `REPO_APNAES`, `apnaes`/`mono`/`admin`/`api` aliases, the `find-monorepo-root` fallback); they're gone from tracked code with a `.env`-example comment showing the pattern. **The much larger `finografic`-branded block in the same file (~50 functions/aliases) was deliberately left untouched** — the doc's checkbox names only the `apnaes` shortcuts, migrating the rest is a materially bigger job (different alias shape — `@`-prefixed fuzzy-jump functions, not simple `cd` aliases) and risks breaking a workflow the user actually relies on daily. Flagged for [P7.1](#p71--readme-for-strangers)/[P7.3](#p73--agent-rules-made-relevant) instead.

### P2.2 — Declarative profile manifests

> **`[OPUS]`** — Genuine design, not transcription: the manifest loader, preset resolution, and the nvm-before-`lib/node.zsh` load-order invariant encoded so it can't be got wrong per-profile. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Today every `profiles/<name>/<name>.zsh` re-exports `ZSHRC_ROOT`, `ZENV_PATH`, `NVM`, then
hand-lists `source` lines. `vscode.zsh`, `codex.zsh`, and `docker-dev.zsh` additionally
hand-roll the entire nvm + pnpm + `lib/node.zsh` boot sequence, three slightly different ways.

> **Done 2026-07-26.** All eight profiles converted. Entry points are now 32–58 lines each (target was "under 100"); `main.zsh` lost ~60 lines of unconditional sourcing.

- [x] Add `core/profile.zsh` providing the loader and two helpers: `zenv-modules` (resolve names → `lib/` barrels) and `zenv-features` (resolve names → profile files). — Plus `zenv-opt-in` (extras), `zenv-validate` (reusable by `zconf doctor`), and `zenv-load` as the entry point.
- [x] Each profile becomes a declaration. Actual shape (the doc's sketch listed `paths` and `banner` as features — see the two deviations below):

  ```zsh
  # _zenvs/home-macos/home-macos.zsh
  ZENV_PRESET=full                      # full | minimal | container | none
  ZENV_MODULES=(llms macos ghostty)     # merged on top of the preset
  ZENV_FEATURES=(backups aliases dev)   # -> $ZENV_PATH/$ZENV.<name>.zsh
  ZENV_OPT_IN=(music/backup-dj-crate music/djay_icloud_sync)
  zenv-load
  ```

- [x] Add presets so the three minimal profiles stop diverging: `minimal` = colors + node + git; `container` = `minimal` + utils, minus macOS anything; `full` = everything portable. `none` added for profiles that want to list every module explicitly (codex uses it).
- [x] **Deviation — `banner` is not a feature.** The doc's example lists it, but banners `echo`, and `lib/widgets.zsh`'s `show-splash-sys-banner` already sources `$ZENV.banner.zsh` during the splash. Making it a manifest feature would print the banner twice. It stays convention-based. (This also fixed a real pre-existing double-banner in `docker-dev`, which sourced its own banner _and_ got the splash one.)
- [x] **Deviation — `widgets` and `ghostty` are in no preset.** `main-splash.zsh` sources `widgets` itself and is its only consumer; `ghostty` hardcodes a macOS config path so it is not portable enough for `full`. Both remain in the registry for profiles to request explicitly.
- [x] **Canonical ordering.** Modules are sourced in the order `ZENV_MODULE_ORDER` defines, _not_ the order a profile listed them — a profile declaring `(widgets git colors dev)` still gets colors first. Asserted by a test.
- [x] **`main.zsh` absorbed into the manifest.** Steps 10–13 (vendor tools, `lib/utils`/`disk`/`doctor`/`node`/`dev`/`ghostty`, and the macOS block) were unconditional; they are now preset content resolved per profile. `vendor/index.zsh` is consequently unused.
- [x] Extract the shared macOS Homebrew-prefix eval into `lib/macos/macos.brew.zsh` (was duplicated in `home-macos.zsh:18-24` and `office-macos.zsh:19-27`). — Done in [P2.1](#p21--the-two-renames-you-asked-for) rather than waiting for the full manifest loader; no reason the two were coupled.
- [x] Preserve the **load-order invariant**: nvm must be initialised before `lib/node.zsh` (`nvm-autoload` silently no-ops otherwise). Encode it in the loader so it cannot be got wrong per-profile. — The `node` module now owns the whole boot: `vendor/pnpm-path.zsh` → `vendor/nvm.zsh` (only when `NVM=true`) → `lib/node.zsh` → `nvm-autoload-init`. That is exactly what `vscode`, `codex` and `docker-dev` each hand-rolled differently. Three tests assert the ordering, including that it holds when other modules are interleaved.
- [x] Validate manifests in `zconf doctor` — unknown module name = error, not a silent skip. — Implemented now as `zenv-validate`, called by `zenv-load` on every shell: an unknown module, unknown preset, or missing feature file fails loudly with the list of known names. `zconf doctor` ([P5.2](#p52--zconf-commands)) can reuse the same function rather than reimplementing it.
- [x] **Bug found while testing, not in the audit**: the loader's local was originally named `modules`, which is a **special read-only parameter** once `zsh/parameter` is loaded — and p10k loads it. Harmless inside a function (the local shadows it) but a live landmine for any top-level use. Renamed to `resolved_modules`.
- [x] Two new test files, both wired into CI: `tests/test-profile-loader.zsh` (23 cases — ordering, the nvm invariant, presets, validation failures, and that all eight real manifests validate) and `tests/test-profile-boot.zsh` (boots every profile with `ZENV_FORCE` and asserts a sentinel function exists — the "profile you can't easily reach" test [P7.4](#p74--ci) asks for).

### P2.3 — Profile inventory pass

> Partly addressed by [P2.2](#p22--declarative-profile-manifests), which converted all eight profiles. What remains below is per-profile content review, not structure.

- [x] `android` — four files, Termux-only. Keep, but verify it still boots; it references `STORAGE_ROOT`/`PATH_ZSHRC` set only inside `determine-environment`. — Converted (`container` preset + `paths`) and boot-tested. The `STORAGE_ROOT` coupling is fixed: it is set by `apply-environment-env` ([P1.4](#p14--fix-the-environment-detection-logic)) and the profile now self-defaults it rather than depending on detection having run. Its `edit()`/`code()` had the same broken quoting as the server profile — `edit` fixed, `code` dropped (it referenced `$IDE`, which is `false` here).
- [ ] **New finding (P2.2 boot test):** `home-linux`'s `hardware` feature runs real hardware probing at profile load (`/dev/input` globbing, `pactl`), printing 4 lines on every shell. Legal per the layer table (profiles may have side effects) but noisy, and it is the same class of thing [P1.2](#p12--purge-source-time-side-effects) removed from `lib/`. Consider making it a `linux-hardware-check` function the user calls. Not changed blind — needs testing on a real Linux desktop.
- [ ] `docker-dev` — keep and simplify per your existing triage (§10 of the audit): generic Linux container profile, no work assumptions. ~~Remove the shebang and top-level output (`docker-dev.zsh` is _sourced_)~~ **done in [P2.2](#p22--declarative-profile-manifests)** (shebang, the "Docker container environment loaded" echoes, the redundant `core/history.zsh` source, and the duplicate banner source all gone; `container` preset now). Still to do: fold `extras/examples/` Dockerfiles down to one `Dockerfile` + one `docker-compose.yml`, and move them to `extras/docker/` so it's obvious they're runnable.
- [x] `vscode` / `codex` — collapse onto the `minimal` preset. They differ meaningfully only in the prompt. — Both converted in [P2.2](#p22--declarative-profile-manifests) and no longer hand-roll the node boot. `vscode` uses `minimal`; **`codex` deliberately does not** — it uses `none` + `(colors node)`, because `git` and `dev` define a large interactive alias surface an agent shell will never use and that can surprise a non-interactive caller. They now differ in the prompt _and_ in that one justified way.
- [ ] `home-linux` — 4 files, currently the least-maintained profile. Either bring it up to the manifest standard as the _reference generic Linux desktop_ profile, or fold it into `server-linux` + a `linux-desktop` feature flag. Recommend keeping it: a public repo benefits from a non-macOS path that actually works.

**Exit criteria:** every profile is under 100 lines; adding a new host is a single 15-line
file; `zsh -n` and a container smoke test pass for all profiles.

---

## Phase 3 — `lib/` consolidation and dedupe

### P3.1 — Delete orphans

Nothing sources these (verified by basename grep across all tracked `.zsh`/`.md`):

- [x] `lib/mongodb.zsh` (73 lines) — delete, or move to `extras/` if you still use MongoDB. — Deleted in [P1.2](#p12--purge-source-time-side-effects) (it also ran `mverSet` at source time).
- [x] `lib/template-tool/` — **8 files, ~900 lines** … This is a scratch workspace. Extract whatever the "FINAL" version was actually for, or delete the directory outright. — Deleted outright in [P1.2](#p12--purge-source-time-side-effects); nothing reusable (one-off merge-conflict triage with a hardcoded 2025 date).
- [x] `lib/k.plugin.zsh` (593 lines) — a vendored copy of `supercrabtree/k`, but `plugins/.zsh_plugins.txt` already loads `k` via Antidote from its own repo. Delete the vendored copy. — Deleted in [P1.2](#p12--purge-source-time-side-effects), with its `.editorconfig` shfmt exemption.
- [x] `lib/dev.jest.zsh` (91 lines) — sourced only by `home-macos`, and it is employer-era Jest tooling. Delete or move to `extras/`. — Deleted in [P1.2](#p12--purge-source-time-side-effects); it ran `jest --clearCache` at source time.
- [x] `themes/gallois-custom.zsh-theme`, `themes/restore-theme.zsh` — verify against `themes/default.theme.zsh`; delete whichever is superseded. — Both deleted: `gallois` is commented out in `plugins/.zsh_plugins.txt`, `powerlevel10k` is the real active theme (confirmed via `bootstrap/04-prompt.zsh`). `themes/README.md` was still documenting gallois as "MY PICK" — corrected to describe p10k as the default and the oh-my-zsh list as alternatives. `default.theme.zsh`'s dead commented-out `gallois-custom` line updated to say what's actually true.
- [x] `.main.zsh.swp` (16 KB tracked vim swapfile) — untracked in [P0.2](#p02--scrub-secrets-and-pii-from-the-working-tree); `plugins/.zsh_plugins.generated.{linux,macos}.zsh` untracked in [P1.2](#p12--purge-source-time-side-effects) and now covered by `.gitignore`.

That's roughly **1,700 lines and 66 MB** removed before a single behavioural change.

### P3.2 — Finish the domain barrels

> **Done 2026-07-26.**

The `vendor` / barrel / `lib/<domain>/` model is already half-built. Finish it:

| Domain    | Was                                                     | Now                                                                                                                                                                                                                                           |
| --------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `git`     | `lib/git.zsh` + `lib/git/` (7 leaves + `index.zsh`)     | `lib/git/index.zsh` was a near-byte-identical, **unsourced duplicate** of `lib/git.zsh` — deleted. `git.tags.README.md` → `docs/git-tags.md`.                                                                                                 |
| `node`    | `lib/node.zsh` + `lib/node/`                            | Unchanged, plus one new leaf (see `dev` row).                                                                                                                                                                                                 |
| `clean`   | `lib/clean.zsh` + `lib/clean/`                          | Already done in [P1.2](#p12--purge-source-time-side-effects).                                                                                                                                                                                 |
| `macos`   | `lib/macos.zsh` + `lib/macos/{dock,time-machine,utils}` | `macos.brew.zsh` already added in [P2.2](#p22--declarative-profile-manifests). `macos.utils.zsh` → `macos.media.zsh` (its actual content: one HEIC-conversion function).                                                                      |
| `dev`     | `lib/dev.zsh`, 340 lines, the largest live module       | Split: `lib/node/node.globals.zsh` (npm/global-install: `versions`, `v`, `latest`, `update`, `kn`, `i`), `lib/dev/dev.workflow.zsh` (everything else — `min`, `deploy-static`, `cx`, log/pm2 helpers). `lib/dev.zsh` is now a 4-line barrel.  |
| `cli`     | `lib/cli/{listing,navigation}` with no barrel           | Added `lib/cli.zsh`; `lib/common.zsh` sources the barrel instead of both leaves directly.                                                                                                                                                     |
| `utils`   | `lib/utils.zsh` + `lib/utils.disk.zsh`                  | `lib/utils.disk.zsh` → `lib/utils/disk.zsh`. Module registry updated (`[disk]=lib/utils/disk.zsh`).                                                                                                                                           |
| `paths`   | `lib/paths.zsh` + `lib/paths/{macos,linux,android}`     | `flatten-path` was already dropped, earlier in the session (P1.3/P4.1).                                                                                                                                                                       |
| `widgets` | `lib/widgets.zsh` (151 lines) + `lib/widgets.readme.md` | Renamed to `lib/splash.zsh`; readme → `docs/splash-widgets.md`. Registry key also renamed `widgets` → `splash` for consistency with the filename — nothing referenced the old key except tests, which are updated. `main-splash.zsh` updated. |

- [x] **Rule to codify:** identical basenames in two places is a smell (this is what made `pnpm` confusing until `vendor/pnpm-path.zsh` was renamed). Role-name the vendor/boot files; domain-name the UX modules. — The `lib/git.zsh` / `lib/git/index.zsh` pair found in this same pass is exactly this smell; resolving it is the rule's first real application.
- [x] Full test suite (63 cases) plus a live interactive shell boot re-verified after every rename in this table: all new function locations resolve (`run`, `min`, `deploy-static`, `cx`, `lg`, `tailc`, `logsr`, `pm2da`, `pm2ll` from `dev.workflow.zsh`; `versions`, `v`, `latest`, `update`, `kn`, `i` from `node.globals.zsh`; `convert-heic` from `macos.media.zsh`; `listing` via the new `cli.zsh` barrel), zero `MISS`.

### P3.3 — Consistency sweep

Apply the recorded conventions everywhere, ideally via a script + a `zconf doctor` check so it doesn't rot:

- [x] `function` keyword + kebab-case names. Offenders included `_gb` (office), `_register_repo_aliases` (README example), `_pm2` (server) — all fixed in earlier passes ([P2.1](#p21--the-two-renames-you-asked-for)/[P3.1](#p31--delete-orphans)).
- [x] No shebang in sourced modules; a boxed `# NOTE:` header instead. Fixed: `main.zsh`, `bootstrap/index.zsh`, `core/env.zsh`, `bootstrap/00-profiling.zsh`, `01-antidote.zsh`, `02-plugins.zsh`, `03-compinit.zsh`, `04-prompt.zsh`, `core/locale.zsh`, `core/options.zsh`, `profiles/docker-dev/docker-dev.banner.zsh`. Confirmed genuinely-executed scripts (`extras/music/*.zsh`, `scripts/docker-cleanup.zsh`, `scripts/bench-startup.zsh`, `scripts/setup/*.zsh`, `tests/*.zsh`, `update-config.zsh`) correctly keep their shebangs. `vendor/index.zsh` was orphaned — deleted outright instead of fixed.
- [x] `[[ ]]` not `[ ]`; quote all expansions. Swept the testable `lib/` tree, `core/`, and `profiles/*` (excluding `extras/hardware/*` — untestable Linux-only hardware scripts — and `extras/music/*` — personal launchd utility scripts — both explicitly deferred as out of scope, matching the P1.2/inertness scoping precedent). `vendor/nvm.zsh`'s bare `[ ]` left untouched — it's vendored upstream nvm code, not ours to restyle. **Two real bugs found, not cosmetic**: `_ga()` in `git.commit.zsh` and `_gb()` in `git.core.zsh` both had `if [[ $1 > "" ]]` — a string _comparison_ (lexicographic `>`) misused as a non-empty test, which is true/false unpredictably depending on `$1`'s content rather than whether it's set. Fixed both to `[[ -n "$1" ]]`. Also fixed: `git.rebase.zsh`, `git.tags.zsh`, `git.stashes.zsh`, `git.submodule.zsh`, `clean/clean.node.zsh` (some converted to `(( ))` arithmetic), `cli/cli.listing.zsh`, `core/options.zsh`, `lib/splash.zsh`, `profiles/home-macos/home-macos.dev.zsh`. **Third real bug found while doing this sweep, not in the original audit**: `lib/fzf.zsh` ran `git clone --depth 1 …/fzf.git ~/.fzf && ~/.fzf/install` **unconditionally at source time** on Linux whenever `~/.fzf` was missing — a network call on every shell start, a real [P1.2](#p12--purge-source-time-side-effects) violation that went undetected because it's Linux-only and all P1.2 inertness testing runs on macOS. Fixed by moving the clone into a named `install-fzf()` function the user calls explicitly, matching `scripts/setup/install-tools.zsh`'s existing pattern for optional installs.
- [x] `${_c}` / `${_0}` from `lib/colors.zsh` — never local ANSI constants. `lib/template-tool/` and its two `colors.zsh`/`__colors.zsh` files were already deleted in an earlier pass. `extras/examples/run-docker-zsh.sh` confirmed correctly exempt — it's bash, not zsh, and cannot source a zsh-syntax file. `profiles/android/android.banner.zsh` was the one real offender left (raw `echo "\e[33m"`/`\e[1m"` instead of sourced vars, plus two dead commented-out color lines) — replaced with `echo "${_y}${_bold}"`, matching the convention already used in `profiles/docker-dev/docker-dev.banner.zsh`.
- [x] `--dry-run` (not `--dry`) on every destructive helper — audited (`lib/clean.zsh`, `profiles/server-linux/server-linux.dev.zsh`); every occurrence repo-wide already uses `--dry-run`, nothing to fix. Confirm-prompt default-last ordering (`(Y/n)`/`(n/Y)`) — audited and **deliberately left as-is**: `git.maintenance.zsh:85` and `home-macos.dev.zsh`'s `_gclean`/`_gclean-orig` label their prompts `(y/n)` with no default (`read -r response` with no `${response:-Y}` fallback, so an empty Enter aborts) — that's intentionally stricter for destructive `reset --hard`/branch-delete operations, not a bug, just an inconsistent label vs. `git.submodule.zsh`'s `(Y/n)` (which does default). Left unchanged rather than force a default onto destructive prompts; a full label-only pass is cosmetic and deferred.
- [x] The two existing helpers — `scripts/normalize-comment-blocks.py` and `scripts/normalize-functions.py` — should be wired to `pnpm normalize` (or ported to `zconf`, [P5.2](#p52--zconf-commands)) and run in CI as a check. — **Done via the port**, which was the better of the two options offered: both scripts are now `zconf normalize`, and the `.py` files are deleted, so the repo has no Python dependency left. Both originals turned out to be broken in ways that would have damaged the repo (see the Phase 5 entry in [Done](#done)); the port fixes both and is idempotent. Not added to CI as a _failing_ check — a formatter that fails the build on a cosmetic diff is noise, and `oxfmt` already occupies that role for every other language here.
- [ ] Section numbers in `main.zsh` comments (`1.`–`16.`) already drift — `7.` is missing entirely. Drop the numbers, keep the boxes. **Deferred** — `main.zsh` has been restructured repeatedly across P2.2/P3.3/P4.4; needs a fresh read-through once structural churn settles, not worth doing mid-churn.
- [x] `main.zsh:92` — `alias vim="${EDITOR} $@"` — already fixed to `alias vim="$EDITOR"` in an earlier pass; confirmed clean.
- [x] Remove the commented-out duplicate `source` lines in `main.zsh` (`fzf.zsh:82`, `colors.zsh:113`) — confirmed already gone (no commented-out `source` lines remain), superseded by earlier P2.2/P4.5 restructuring.
- [ ] `print`/`printf` over `echo "\n..."`/`echo -e` — **explicitly deferred**, out of scope for this batch: touches `lib/clean.zsh`, `lib/clean/clean.node.zsh`, `lib/git/git.submodule.zsh`, `lib/git/git.maintenance.zsh`, `lib/git/git.commit.zsh`, `profiles/server-linux/server-linux.dev.zsh`, `profiles/home-macos/home-macos.dev.zsh` — behavior-neutral but wide (many lines per file); revisit as its own focused pass rather than folding into this batch.

### P3.4 — `lib/colors.zsh`: stop exporting

- [x] 23 `export _X=` color vars leak into the environment of **every child process** (`env` output, subprocess memory, anything that dumps env in logs). They are only needed in-shell: change to `typeset -g`. — **Real bug found while doing this, not cosmetic**: `typeset -g` on a name that is _already_ exported does not strip the export flag, only the value. Every one of these vars had been `export`ed by the old file, so any long-lived ancestor shell still running old config (a tmux server, a login shell predating the update) already has them exported — and `typeset -g` alone would keep silently leaking them into child processes on exactly the machines this fix is meant to help. A bare `zsh -f` test cannot catch this: it starts with a clean environment. Fixed with an explicit `typeset +x` pass after all assignments; verified against a harness that pre-exports the old-style vars before sourcing (the contaminated-ancestor-shell scenario), which reproducibly failed before the fix and passes after. New permanent regression test in `tests/test-lib-inert.zsh`.
- [x] Caveat first: verify nothing that runs as a _separate process_ depends on them — check `extras/music/*.zsh` (launchd jobs), `scripts/*.sh`, and `extras/examples/run-docker-zsh.sh`. Anything that does should source `lib/colors.zsh` itself. — Confirmed: all five consumer scripts already self-source `lib/colors.zsh`. `run-docker-zsh.sh` is bash, not zsh, and defines its own raw ANSI vars — correct as-is, since it cannot source a zsh-syntax file.
- [x] `lib/colors.zsh:5` — `export env EXA_COLORS=…` exports a variable literally named `env`. Fix to `export EXA_COLORS=…`.
- [ ] Consider `%F{…}`/`autoload colors` for prompt contexts, but raw escapes are fine for `print` output — not worth churning.
- [x] **Second real bug found while rewriting this file, not in the audit**: `_B` was defined twice — first as generic bold (`\033[1m`), then a few lines later silently reassigned to bold+blue (`"$_B\033[34m"`) to fit the uppercase-letter convention for the other colors. Any caller wanting plain bold via `${_B}` got bold-**blue** instead — and since ANSI foreground codes don't compose (the last one wins), `lib/git/git.maintenance.zsh`'s `${_y}${_B}DELETE` actually rendered blue, not yellow-bold as the code implies. Fixed by giving generic bold its own name (`_bold`) and updating the one real consumer.

### P3.5 — Colors: guarded explicit sourcing

**Your open question, answered:** you can have explicitness _and_ speed. Add a load guard to
`lib/colors.zsh` and then source it explicitly wherever it's used.

```zsh
# top of lib/colors.zsh
(( ${+_ZSHRC_COLORS_LOADED} )) && return 0
typeset -g _ZSHRC_COLORS_LOADED=1
```

Then every module that uses `${_c}` opens with `source "$ZSHRC_ROOT/lib/colors.zsh"`. The
first call does the work; the other ~25 return after one arithmetic test — call it
single-digit microseconds each, i.e. unmeasurable. You get: self-documenting dependencies,
modules that work standalone (`zsh -f -c 'source lib/git.zsh'`), and no double-parse.

- [x] Add the guard to `lib/colors.zsh`. — Done exactly as specified; verified idempotent (a second `source` is a no-op that leaves existing values untouched).
- [x] Add the same guard idiom to every barrel (`lib/git.zsh`, `lib/node.zsh`, …) — it also makes re-sourcing your config for testing free. — Added `_ZSHRC_<NAME>_LOADED` guards to all 14 remaining `lib/*.zsh` barrels: `clean`, `cli`, `common`, `dev`, `doctor`, `fzf`, `ghostty`, `git`, `llms`, `macos`, `node`, `paths`, `splash`, `utils`.
- [x] Add explicit `source` lines to the ~25 modules that reference color vars. — Added `source "$ZSHRC_ROOT/lib/colors.zsh"` to every leaf module found actually using `${_c}`-style vars without it: 4x `lib/clean/*.zsh`, `lib/cli/cli.listing.zsh`, `lib/dev/dev.workflow.zsh`, 5x `lib/git/*.zsh`, `lib/macos/macos.time-machine.zsh`, `lib/utils.zsh`, `lib/splash.zsh` (uncommented an existing but disabled line), and 6 profile files (`android.banner.zsh`, `docker-dev.aliases.zsh`, `docker-dev.banner.zsh`, `home-linux.dev.zsh`, `office-macos.dev.zsh`, `server-linux.banner.zsh`). **Real bug found doing this, not cosmetic**: `lib/git/git.tags.zsh` had its own hand-rolled, hardcoded-bold color palette (`_y='\033[1;33m'`, etc.) instead of sourcing `lib/colors.zsh` — a genuine duplicated palette (the thing this task's exit criteria explicitly calls out). Deleted the local definitions and sourced `lib/colors.zsh` instead. Net effect: `_gtag`'s warning/error text renders in the same weight as every other git helper now instead of its own one-off bold variant — a real (minor, cosmetic-only) rendering change, not a correctness fix, but worth naming since it changes visible output.
- [x] Verify with the benchmark ([P4.3](#p43--measure-it)): measure before and after; if the delta exceeds 5 ms, revert to implicit and record the measurement in this doc. (Prediction: it will be under 1 ms.) — Ran `scripts/bench-startup.zsh --zenv home-macos -n 15` after all guards were added: 563/591/692 ms (min/p50/p95), consistent with the P4.4 post-fix baseline already on record in `docs/benchmarks/`. No measurable regression from the added guards, as predicted.

**Exit criteria:** `lib/` has no orphans, no duplicated palettes, one barrel per domain, and
`zconf doctor` passes clean.

---

## Phase 4 — Startup performance

### P4.1 — Remove Node from the startup path

Two `node` process spawns per interactive shell, ~30–80 ms each on macOS:

> **Done 2026-07-26**, pulled forward from Phase 4 because the [P0.2](#p02--scrub-secrets-and-pii-from-the-working-tree) scrub untracked `packages/node/dist/`, which these calls depended on.

- [x] `main.zsh:110` — `node packages/node/dist/spinner.mjs`. This is a **deliberate 200 ms delay to give a "busy" impression**. Delete it. If you want the visual, a pure-zsh spinner around the actual work is a few lines and costs nothing; a fake delay is 200 ms of your life per shell.
- [x] `main.zsh:163` — `export PATH=$(node …/build-path.mjs)`. Replaced by `typeset -U path PATH` in `bootstrap/index.zsh` ([P1.3](#p13--single-owner-for-path)). Verified live: `typeset -p path` reports `typeset -aUT`, and all 54 entries are unique.
- [x] `lib/paths.zsh:14-16` — `flatten-path`, the third caller of the same script. Delete.

### P4.2 — Delete orphaned Node utilities

> **Done 2026-07-26**, same pass as [P4.1](#p41--remove-node-from-the-startup-path).

- [x] `packages/node/src/detect-env.ts` — a full TypeScript reimplementation of `core/env.zsh`'s `determine-environment`, referenced nowhere. Delete (D6: env detection stays in zsh — it must work before Node exists, e.g. on a fresh server).
- [x] `packages/node/spinner.mjs` (stray root copy, differs from `dist/`) — delete.
- [x] `packages/node/dist/**` — committed build output, and `.gitignore` already lists `dist/`. Untrack.
- [x] With `spinner`, `build-path`, and `detect-env` all gone, `packages/node` is empty: delete it, along with `tsdown.config.ts`, its `tsconfig.json`, and the `build:node`/`typecheck:node` scripts. This also resolves the type-aware oxlint failures on unresolved `fs`/`process`/`child_process` — by deleting the dead code rather than repairing it.
- [x] Keep `pnpm-workspace.yaml` **only** if [Phase 5](#phase-5--typescript-where-it-actually-earns-its-place) goes ahead (it will re-populate `packages/`). Otherwise flatten. — **Kept** (D6 confirms Phase 5 goes ahead; `packages/` is now empty awaiting `zconf`).

### P4.3 — Measure it

> **Done 2026-07-26.** Done out of Phase order, ahead of Phase 3, because three phases of
> load-path changes (node removal, side-effect purge, manifest loader) had already landed
> with zero measurements — the exact situation this task exists to prevent from
> compounding further.

You cannot defend a budget you don't measure. This is a prerequisite for the rest of the phase.

- [x] Add `scripts/bench-startup.zsh`: N cold `zsh -i -c exit` runs, report min/p50/p95, accept `ZENV=<profile>` to benchmark each profile, and diff against a committed baseline in `docs/benchmarks/`. — Built as `--zenv <profile>` / `--all-profiles`, `-n`, `--json`, `--save`. **Real correctness finding, not cosmetic**: `ZENV_FORCE=vscode`/`codex` alone does _not_ exercise those profiles' fast paths — `main.zsh`'s early exits call `is-agent-shell`/`is-ide-shell` directly against real env signals (`IS_CODEX`, `TERM_PROGRAM`), not `$ZENV`. A benchmark using only `ZENV_FORCE` would have quietly measured the _slow_ path for the two profiles that most need to be fast. The script sets the real trigger per profile instead (`TERM_PROGRAM=vscode`, `IS_CODEX=true`, `IN_DOCKER=1` for docker-dev). **Follow-up from real-machine testing**: the first version ran all 160 shells (8 profiles × 20 runs) silently, with output only at the very end — indistinguishable from a hang. Added a per-run spinner + `profile run N/M` progress line to stderr, gated on `[[ -t 2 ]]` so it's silent (and doesn't pollute logs) when piped or run in CI, and the table now prints one row per profile as it finishes instead of holding everything until the end.
- [x] **Bug found and fixed while building this, not in the audit**: the first version of the JSON writer used `local name` (bare, no `=`) to redeclare a variable that was already `local` from an outer scope, inside a `{ ... } > file` redirect. In zsh this is not a no-op — `typeset`/`local` with a bare name on an _existing_ parameter switches into **display mode** and prints `name=value` to stdout. That printed straight into the JSON file on the very first `--save` run, corrupting it with three stray lines. Fixed by declaring locals once, with explicit values, and factoring row-parsing into one `parse-row` helper instead of three inline copies.
- [x] Record the current baseline in this doc _before_ changing anything, so each subsequent phase can claim a real number. — Recorded in `docs/benchmarks/baseline.json`, initially from this AI agent's sandbox (which showed signs of startup-specific contention — a `gitstatusd` init failure; `node --version` costing 1.5s of `zprof` self-time vs 17ms standalone), **then superseded the same day by the maintainer re-running it on their real Mac**, which is now the authoritative committed baseline. Full history in `docs/benchmarks/README.md`. The real-machine numbers land faster than the sandbox's but confirm the same shape: **the config genuinely is ~8–10x over the 400ms/150ms budget**, not a measurement artifact. Cross-profile ratios hold on both runs: `codex` (1,065ms p50) ≪ `docker-dev` (1,490ms) < `vscode` (2,910ms) ≪ full profiles (~4,200–4,250ms) — confirming the bootstrap early-exit architecture works as designed, and surfacing that `vscode`'s "minimal" profile still pays the full `antidote`/`compinit`/p10k-prompt cost in `bootstrap/`, unlike `codex`. Real finding for [P4.4](#p44--structural-speedups).
- [x] Add `bootstrap/00-profiling.zsh` documentation: how to get a `zprof` breakdown in one command (`ZSHRC_PROFILE=1 zsh -i -c exit`). — Implemented as an actual one-command mechanism, not just documentation: `ZSHRC_PROFILE=1` now gates `zmodload zsh/zprof` and a `zshexit` hook that prints the report automatically, replacing a manual comment-out-this-line workflow. While there, removed a second, redundant `typeset -U PATH` in this file — [P1.3](#p13--single-owner-for-path)'s `typeset -U path PATH` in `bootstrap/index.zsh` already owns this and runs first.
- [x] Add the budget assertion to CI (soft-fail at first — CI runners are noisy; compare ratios between profiles rather than absolute ms). — New `startup-budget` job, `continue-on-error: true`, asserts `codex` p50 < `home-linux` p50 on the Ubuntu runner (the two Linux-compatible profiles). Verified locally end-to-end with the exact extraction logic CI runs.

### P4.4 — Structural speedups

> **`[OPUS]`** — Highest payoff, silent-failure footgun (`autoload`/`fpath` ordering, `zcompile` staleness, lazy shell-outs). One change per benchmark run. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Ordered by payoff-to-risk. Do them one at a time with a benchmark run between each.

- [x] **Remove the duplicate nvm load — not on the original list, and it dwarfed everything on it.** Phase-by-phase instrumentation (2026-07-26) showed `bootstrap/02-plugins.zsh` was **1,218 ms of a 1,251 ms bootstrap (97%)**, and per-plugin timing narrowed that to `lukechilds/zsh-nvm` (616 ms) + `ohmyzsh/plugins/yarn` (547 ms). Root cause: **nvm was loaded twice per shell** — once by the plugin in bootstrap, once by `vendor/nvm.zsh` via the manifest's `node` module. `nvm.sh` alone costs 438 ms and `NVM_LAZY_LOAD` does not help (490 ms unset / 597 ms true / 515 ms false — the cost is `nvm.sh`, not eagerness; and it was being set _after_ bootstrap anyway, so it could never have applied to the plugin). Nothing referenced the plugin's own features, and this repo already owns the full nvm lifecycle (`vendor/nvm.zsh` + `lib/node/nvm-autoload.zsh`), so the plugin was pure duplication. **Removed. A/B same-environment, n=8: `home-macos` 5,656 → 1,993 ms (−65%), `vscode` 3,707 → 1,389 ms (−63%); the plugin bundle itself 1,228 → 103 ms.** `yarn` fell 547 → 49 ms as a side effect — it is an nvm-shimmed binary, so its `yarn global bin` shell-out had been paying the same double-load tax. Full writeup in [`docs/benchmarks/README.md`](../benchmarks/README.md).
- [ ] **`autoload` the cold functions.** ~7,300 lines of zsh are parsed on every shell, and most of it is functions you call rarely. Move rarely-used function bodies into a `functions/` directory on `fpath` with `autoload -Uz`, so startup registers a name instead of parsing a body. Best candidates: `lib/git/git.maintenance.zsh` (276 lines), `lib/git/git.commit.zsh` (230), `lib/git/git.tags.zsh` (147), `lib/git/git.stashes.zsh` (134), `lib/clean/*` (~350), `lib/llms.zsh`, `lib/utils/disk.zsh`. Aliases and completions must stay eager; function bodies need not be. This is the single biggest available win and it is the idiomatic zsh answer.
- [ ] **`zcompile` the hot path.** Compile `main.zsh`, `bootstrap/*`, and the eager barrels to `.zwc` with a staleness check. Gitignore the `.zwc` files (you already have stale committed ones under `themes/p10k/`).
- [ ] **Audit shell-outs on the load path.** Currently on every start: `sw_vers` ×2, `uname` ×3, `hostname`, `ipconfig`/`curl`, `brew shellenv` (an eval of a subprocess), `node` ×2, `gh auth login`, `launchctl list` ×2, `socketfilterfw`, plus the splash's `tmutil`, `lsof`, `neofetch`. Replace what you can with zsh builtins (`$OSTYPE`, `$CPUTYPE`, `${(%):-%m}` for hostname), make the rest lazy, and cache the genuinely slow ones (`brew shellenv` output) in `${XDG_CACHE_HOME}` keyed by brew version.
- [x] **Make the splash opt-out.** — Done. Measured at ~475 ms, not 300: `show-os-version-and-sys-info` 181 ms (`node`/`pnpm --version`), `show-ports` 76 ms (`lsof`), `show-tmutil-snapshots` 73 ms, `show-splash-neofetch` 48 ms, `show-custom-launch-agents` 36 ms. `ZSHRC_SPLASH=0` disables it; anything else, including unset, shows it. **The plan's "skip it for non-login / nested shells" was implemented, then rejected by the user within minutes** — typing `zsh` in an existing terminal showed nothing and needed `ZSHRC_SPLASH=1` to force. That correction is right: typing `zsh` is a deliberate act and the splash is its expected result, and a performance argument does not outrank what the config's owner wants their own shell to do. **Consequence: this is a switch, not a saving.** The ~475 ms is still paid on every interactive shell and remains the largest single target left after `nvm.sh`. `bench-startup.zsh` forces `ZSHRC_SPLASH=1` regardless, so the benchmark cannot drift if the default is ever revisited.
- [x] **Skip nvm's no-op `nvm use` / `nvm alias default`** — not on the original list. `vendor/nvm.zsh` measured **1,217 ms from `$HOME`** vs 505 ms inside a repo; the 712 ms gap is those two commands, which run only in the no-`.nvmrc` branch, i.e. the ordinary case of opening a terminal in `$HOME`. Both were no-ops: sourcing `nvm.sh` already leaves `NVM_BIN`, `nvm current` and `alias/default` correct. Guarded with an equivalent microsecond check; verified it still repairs a deliberately stale alias rather than just skipping. **1,217 → ~499 ms (−59%).**
- [x] Re-run the benchmark; update `docs/benchmarks/`. — Cumulative table recorded in [`docs/benchmarks/README.md`](../benchmarks/README.md). Sandbox, n=10, splash forced on: `home-macos` −69%, `vscode` −67%, `office-macos` −66%, `home-linux`/`server-linux` −63%, `android` −77%. `codex` and `docker-dev` moved only ~6%, which is the expected result rather than a disappointment — both already skipped the plugin bundle via their bootstrap early exits, and that is precisely where the nvm duplication lived. **Real-machine re-run done later the same day** — `baseline.json` now holds post-change numbers (`codex` ~56ms, `home-macos` ~547ms), matching or beating the sandbox prediction. See the P4.4 Done-log entry below.
- [x] **Lazy nvm** — the "make the rest lazy" half of the shell-out audit, and the largest single win after the plugin removal. `vendor/nvm.zsh` now reads `$NVM_DIR/alias/default`, puts that version's `bin` on `PATH` directly, and does **not** source `nvm.sh` (~449 ms + 58 ms). `node`/`npm`/`npx`/`pnpm`/`yarn` all live in that directory so they work immediately; `nvm.sh` loads on demand — first `nvm` call, or first `.nvmrc` wanting a _different_ version. `load-nvmrc` compares against `$NVM_BIN` before doing anything, so an `.nvmrc` matching the default costs nothing. Falls back to the original eager path when `alias/default` isn't a plain installed `X.Y.Z`; `ZSHRC_NVM_LAZY=0` forces eager. **2.5 ms vs 584 ms on the common path.** Verified across all four load scenarios plus the real `cd` workflow (all four version transitions correct), the `nvm` stub, and the escape hatch.
- [x] **Shell-out audit (partial)** — `pnpm --version` (192 ms; pnpm is a Node program) now cached on disk keyed by resolved binary path + mtime; `node --version` eliminated via `${NVM_BIN}` expansion; `OS_BUILD` deleted (a second `sw_vers`, ~15 ms, read by nothing); `uname -m` → `$CPUTYPE`; `hostname` → `${(%):-%M}`. Splash output verified byte-identical.
- [ ] **Still not done:** `autoload` the cold functions and `zcompile` the hot path. After the wins above the profiles sit at **63–778 ms** in the sandbox — `codex` already meets its 150 ms budget, and the full profiles would be under 400 ms with the splash off. What remains, by size: the splash (~475 ms, deliberately kept on), the antidote bundle (~97 ms), `compinit` (~22 ms), then eager `lib/` parsing, which is what these two items would actually address. Also still open: caching `brew shellenv`.

**Exit criteria:** zero `node` spawns at startup, a committed benchmark baseline, full profile
under 400 ms, minimal profiles under 150 ms.

### P4.5 — `_zenvs/` → `profiles/` rename (D2, confirmed)

> **Confirmed by the user 2026-07-26** — promoted out of [Phase 8](#phase-8--optional-polish)'s
> optional-polish list. Placed here, at the end of Phase 4, because it is a pure path rename
> and every earlier phase kept churning the very files it touches (P2.1 renamed a profile,
> P2.2 rewrote all eight, P4.4 is still editing the load path). Doing it once, last, avoids
> re-doing it. Sonnet-tier: mechanical, with tests and CI to catch a miss.

> **Done 2026-07-26.**

- [x] `git mv _zenvs profiles` (keeps history for all 8 profile directories).
- [x] Update path strings — `$ZENV_PATH` is built in exactly two places (`main.zsh`, and each profile's own header), plus `core/profile.zsh`'s feature resolution and `lib/widgets.zsh`'s banner lookup. Keep `$ZENV` as the variable name (D2's own recommendation) so the churn stays limited to literal `_zenvs` strings. — Also caught two more call sites the estimate missed: `main.zsh`'s two early-exit `source` lines (codex, vscode) and the same file's step-10 `source`.
- [x] Update `tests/test-profile-boot.zsh`, `tests/test-profile-loader.zsh`, `scripts/bench-startup.zsh`, `README.md`, `AGENTS.md`, `.agents/handoff.md`, and this doc. — `bench-startup.zsh` needed no change (it never referenced profile paths directly). Also updated: `.github/workflows/ci.yml` (a comment), `.vscode/settings.json` (a file-nesting pattern), `extras/examples/DOCKER_QUICKSTART.md`, `docs/todo/ROADMAP.md`.
- [x] **No compat shim.** The original bullet offered one "if you want to be gentle to your other machines" — unnecessary here: `$ZSHRC_ROOT` is a git checkout, so any other machine gets the rename atomically on its next `git pull`, and a stale shim would just be one more thing to remove later. The one real risk is a machine mid-`zupdate` during the rename, which re-cloning or a plain `git pull` resolves.
- [x] Grep sweep for stragglers: `grep -rn "_zenvs" --include="*.zsh" --include="*.md" --include="*.yml" .` must return nothing but history notes in `docs/todo/` and `.agents/`. — Confirmed zero matches in any `.zsh`/`.json`/`.yml` file. While updating `README.md` anyway, fixed three more items found in passing: a misaligned tree-diagram line, a stale "Spinner + PATH deduplication" feature row (both `packages/node` and `tools/` are long gone), and a stale manual-`zmodload zsh/zprof` troubleshooting snippet superseded by `ZSHRC_PROFILE=1` ([P4.3](#p43--measure-it)).
- [x] Full test suite re-run after the rename: 22 + inert + 25 + 8 = all passing, plus a live interactive shell boot verified (manifest resolves, `nvm`/`pnpm`/aliases all intact, PATH still de-duplicated).

---

## Phase 5 — TypeScript, where it actually earns its place

You want more TypeScript; the repo currently has TS in the _worst_ possible place (the
startup hot path) and nowhere useful. The fix is not less TypeScript — it's moving it.

**The rule:** anything that must run on every shell, or on a machine where Node may not
exist (a fresh VPS, a container, a recovery shell), stays pure zsh. Everything you invoke
_deliberately_ as a maintainer is fair game for TS — and benefits enormously from types,
tests, and real argument parsing.

### P5.1 — Create `packages/zconf`

> **`[OPUS]`** — Net-new TypeScript package: types, Vitest, `bin` entry, build wiring. PAUSE and suggest switching to Opus before starting. Contiguous with P5.2 — batch both in one Opus session. See [Model routing protocol](#model-routing-protocol).

- [x] A single CLI, `zconf`, in `packages/zconf/` — TS, built with tsdown (already your toolchain), `bin` entry, invoked via `pnpm zconf …` and a thin `zconf` zsh wrapper for interactive use. — Done. The wrapper prefers `dist/`, falls back to running from source via `tsx` so the tool works in a fresh checkout before anyone has built it, and refuses cleanly when Node is absent. Registered as a `zconf` module in the `full` preset.
- [x] Styling per your existing `.github/instructions/code/picocolors-cli-styling.instructions.md` — that instruction file finally has a real consumer. — `src/utils/picocolors.ts` exports the shared `pc` alias; nothing else imports `picocolors` directly.
- [x] Vitest tests for all pure logic (source-graph parsing, manifest validation, benchmark stats). This is what gives the public repo credibility, and none of it can be tested sanely in zsh. — 169 tests across 10 files covering the zsh reader, the load graph, manifest resolution, all nine doctor rules, the PII patterns, the benchmark stats, both normalisers, and argument parsing.
- [x] Node typings configured properly this time (`@types/node`, `tsconfig` `"types"`), which closes the type-aware oxlint failures. — `@types/node` installed, `"types": ["node"]` set, `strict` plus `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes`. `tsc --noEmit` and type-aware oxlint both pass.

### P5.2 — `zconf` commands

> **`[OPUS]`** — Static analysis over a file graph (`doctor`, `graph`, `scan`) with Vitest coverage. PAUSE and suggest switching to Opus before starting (or continue the P5.1 Opus session). See [Model routing protocol](#model-routing-protocol).

| Command                    | What it does                                                                                                                                                                                                                                                                                                                     | Why TS, not zsh                                                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `zconf doctor`             | Lints the repo against [the contract](#guiding-principles--the-load-model-contract): orphaned modules (nothing sources them), broken `source` targets, side effects at top level in `lib/`, unknown names in profile manifests, missing barrels, non-kebab-case function names, shebangs in sourced files, duplicated basenames. | Static analysis over a file graph. Miserable in zsh, natural in TS, and _testable_.       |
| `zconf graph`              | Emits the real load-order graph as mermaid, straight into `docs/ARCHITECTURE.md`. Also `--profile <name>` for one profile's resolved load order.                                                                                                                                                                                 | Keeps the diagram true forever instead of hand-maintained and instantly stale.            |
| `zconf scan`               | Secret/PII scan: IPv4 literals, emails, `/Users/<name>`, known personal tokens. Runs in CI and as a pre-push hook.                                                                                                                                                                                                               | The guard that lets you sleep after going public.                                         |
| `zconf new-profile <name>` | Scaffolds `profiles/<name>/` from templates with a valid manifest.                                                                                                                                                                                                                                                               | Templating + prompts.                                                                     |
| `zconf bench`              | Wraps `scripts/bench-startup.zsh`, does the stats, renders the table, diffs the baseline.                                                                                                                                                                                                                                        | Stats and formatting; the _measuring_ stays a zsh script since it must spawn real shells. |
| `zconf normalize`          | Ports the two Python normalizers (comment blocks, function style) so the repo has one tooling language instead of three.                                                                                                                                                                                                         | Removes the Python dependency entirely.                                                   |

- [x] Wire `doctor` + `scan` into CI and `lint-staged`. — Added a `zconf` CI job running tests, typecheck, `doctor` and `scan`. Deliberately kept the existing grep-based `secret-scan` job alongside it: that one is dependency-free and still runs if this package is ever broken, and the two use different patterns. Not wired into `lint-staged` — `doctor` and `scan` are whole-repo checks whose answers do not depend on which files are staged, so per-commit runs would cost time without changing the result; CI and a pre-push hook ([P6.1](#p61--rewrite-update-configzsh)) are the right places.
- [x] Explicitly **out of scope for TS**: environment detection, `PATH` building, the spinner, and `zupdate`. All must work without Node. — Honoured. `lib/zconf.zsh` is only a wrapper and checks for `node` before doing anything, printing a clear message (and reminding you the shell itself does not need it) rather than failing obscurely.

**Exit criteria:** `pnpm zconf doctor` is green, CI runs `doctor` + `scan`, and `packages/`
contains one real, tested package instead of aspirational scaffolding.

---

## Phase 6 — `zupdate` and git hygiene

### P6.1 — Rewrite `update-config.zsh`

> **`[OPUS]`** — Must be correct and fail-safe on a Node-less server: staging semantics, rebase-conflict path, pre-push `zconf scan`. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Current flow: `fetch → add . → commit -m "updated from: $ZENV" → pull --rebase → push`. It
`git add .`s everything unseen and writes a commit message that **its own commitlint hook
rejects** — 570 commits of history prove the hook is being bypassed.

- [x] `zupdate "<message>"` → uses it; if there's no conventional-commit type prefix, default to `chore:`. — `zu-normalize-message`, tested against scoped types, `!` breaking-change markers, and the near-miss cases (`features are nice` must NOT count as a `feat` prefix).
- [x] `zupdate` (no args) → open `$EDITOR` for a real message, like `git commit`. Never auto-generate silently. — Implemented by calling `git commit` with no `-m`, so the editor, the template and the commitlint hook all behave exactly as they normally do rather than being re-implemented.
- [x] `zupdate --sync` → the only path that auto-messages, as `chore(sync): update from ${ZENV}` — valid per commitlint, and greppable for the later squash.
- [x] `zupdate --dry-run` → show what would be staged, committed, and pushed. Nothing else. — Verified by test that it creates no commit and leaves the index empty.
- [x] Show a `git status --short` summary and require confirmation before `git add .` (default `(Y/n)`), or better: stage tracked modifications only (`git add -u`) and list untracked files separately so a stray 50 MB file can't sneak in — which is how the binaries got committed in the first place. — Took the "or better" option. Untracked files are listed **with their sizes** so a large one is obvious, and need `--all` or an explicit `git add`. Confirmation prompt has the default last, per convention; `-y` skips it.
- [x] Keep `set -e`, `fetch` first, `pull --rebase`, and add a clean failure path when the rebase conflicts (currently `set -e` leaves you mid-rebase with no message). — `err_exit`/`pipe_fail` are set via `setopt local_options` inside the main function rather than globally, so the file can be sourced by its tests without leaving `err_exit` on in the caller. Rebase conflicts now print the recovery steps. It also refuses to start if a rebase is already in progress.
- [x] Add a pre-push `zconf scan` call so PII can never be pushed again. — Uses `zconf scan` when Node and a build are present, and falls back to a dependency-free `git grep` mirroring the CI job otherwise, so the check still runs on a bare server. Never silently skipped — only skippable with an explicit `--no-scan`, which warns.
- [x] Stays **pure zsh** — it must work on a server with no Node.

**Also found and fixed while doing this, not in the plan:**

- `~/bin/zupdate` called the script with **no arguments at all**, so every flag and the commit message would have been silently dropped — `zupdate "my message"` behaved identically to a bare `zupdate`. The launcher now lives in the repo at `bin/zupdate` (version-controlled next to what it launches) and forwards `"$@"`; `~/bin/zupdate` is a symlink to it.
- The old script pushed to a hardcoded `origin`, but `master` actually tracks `github`. It now resolves the branch's real upstream and **prints where it is about to push**, which matters while [P0.1](#p01--decide-and-execute-the-history-strategy) is still open.
- **A real bug the new test suite caught in the new code**: the secret scan runs _after_ the commit, so a blocked push leaves a committed-but-unpushed change. The next run saw a clean working tree, took the "nothing to commit" path, and returned without pushing — stranding that commit on the machine indefinitely. Fixed by sharing one `zu-push-if-ahead` step between both paths; the regression test was confirmed to fail when the fix is reverted.

### P6.2 — History

- [ ] If D1 = fresh repo: this is solved by construction. Nothing to do.
- [ ] If D1 = filter-repo: after [P6.1](#p61--rewrite-update-configzsh) makes sync commits identifiable, squash contiguous `chore(sync)` runs in one scripted pass. Tag `archive/pre-rewrite` first, do it from one machine while the others are idle, and re-clone everywhere afterwards.
- [ ] Either way: keep husky + commitlint. They were right; `zupdate` was wrong.

---

## Phase 7 — Documentation, agent rules, CI

### P7.1 — README for strangers

The current README is a good _inventory_ and a poor _pitch_. For a public repo it needs to
answer "why would I read this?" in the first screen.

- [x] Lead with the idea: one config tree, N host profiles, auto-detected, measurably fast. — New opening line does this directly, with the two most credible numbers (`codex` ~56 ms, a full shell ~550 ms) in the first paragraph rather than buried in a table further down.
- [ ] A terminal screenshot or asciinema cast (you have `zsh.png` — replace it with something current). — **Not done — genuinely can't be from here.** Capturing a real terminal screenshot or asciinema cast isn't something a coding agent can produce; this needs you. Confirmed `zsh.png` is stale (last committed 2021, predates this entire refactor) rather than guessing it might still be fine — it should be replaced, not restored.
- [x] Startup numbers from the real benchmark, per profile. This is the credibility line. — A 3-row highlight table right after the pitch (`codex`/`vscode`/`home-macos` against their budgets), linking to `docs/PERFORMANCE.md` for the full 8-profile table and the change log behind the biggest win.
- [x] "Try it in 30 seconds" — the Docker one-liner, before any install instructions. — Now the second section, immediately after the pitch and before "Quick setup".
- [x] "Make it yours" — `.env` flags, `zconf new-profile`, the `REPO_ALIASES` registry.
- [x] Move the structure tree and load order to `docs/ARCHITECTURE.md`; link, don't inline. — The full tree and boot sequence live in `docs/ARCHITECTURE.md`; the README keeps a trimmed, top-level-only tree (enough to orient, not the full `profiles/*` fan-out) plus a one-line summary of the load order with a link onward.
- [x] Fix what's now wrong: "eight host profiles … apnaes", the `packages/node` row, `tools/` binaries, and the `_register_repo_aliases` example (snake_case, violating your own convention). — `apnaes` reference and `tools/` row were already gone (fixed in earlier phases); `_register_repo_aliases` was already corrected to kebab-case in an earlier pass. The one real fix needed here: the structure tree's `packages/` row said "zconf TypeScript toolkit (planned; empty for now)" — stale since Phase 5 shipped it — now reads `packages/zconf/ # Maintainer CLI (TypeScript): doctor, scan, graph, bench, normalize`.

### P7.2 — Docs set

- [x] `docs/ARCHITECTURE.md` — layers, contract, generated mermaid diagram, `PATH` ownership. — Done as part of [P1.1](#p11--write-the-contract-down).
- [x] `docs/PROFILES.md` — the manifest reference, and a worked "add your own host" walkthrough. — Includes the preset table, the `determine-environment` precedence order, an inventory of all 8 current profiles, and the `zconf new-profile` fast path plus the by-hand fallback.
- [x] `docs/PERFORMANCE.md` — budget, how to profile, benchmark results. — Deliberately a short entry point (budget, current numbers table, how-to-measure) that links onward to `docs/benchmarks/README.md` for the full change log, rather than duplicating ~240 lines — one source of truth per fact, same rule this repo enforces on the code.
- [x] `docs/CONVENTIONS.md` — the zsh style rules from [P3.3](#p33--consistency-sweep), as the human-readable pair to `zconf doctor`. — Covers every rule `doctor` checks (function naming, `[[ ]]`, no shebang in sourced files, comment blocks, colors, `--dry-run`, confirm-prompt defaults, `echo`→`print`) plus the side-effect rule and how to check your work locally before CI does.
- [x] Fold in the scattered readmes: `lib/widgets.readme.md`, `lib/git/git.tags.README.md`, `lib/template-tool/README.tools.md`, `themes/README.md`, `tools/bin-*/INSTALLS.md`, `tools/bin-arm64/OLLAMA.md`, `extras/music/README*.md`. — Confirmed already done by earlier phases: `git.tags.README.md` → `docs/git-tags.md`, `tools/bin-arm64/OLLAMA.md` → `docs/OLLAMA.md`, `template-tool` and all of `tools/` deleted outright. `themes/README.md` and the two `extras/music/README*.md` files are left as-is — each is a small, self-contained doc correctly scoped to its own directory, not a stray fragment to consolidate.

### P7.3 — Agent rules, made relevant

- [x] `.github/instructions/code/` is React/TypeScript boilerplate — `provider-context-patterns`, `typescript-patterns`, `modern-typescript-patterns` — in a zsh repo. Delete `provider-context-patterns` outright; keep the TS ones only if scoped to `packages/zconf/**` via frontmatter globs. — `provider-context-patterns.instructions.md` deleted (pure React, no equivalent anywhere in this repo). `typescript-patterns` and `modern-typescript-patterns` scoped with `applyTo: "packages/zconf/**"` frontmatter, each with a one-line note explaining the scope.
- [x] `general.instructions.md` mandates strict TS / camelCase / PascalCase components. Rewrite as zsh-first: module load order, `function` + kebab-case, color vars, boxed comments, `--dry-run`, "modules" terminology, the `.env`/profile model, and the side-effect rule. — Rewritten: leads with the load-model contract and a pointer to `zconf doctor`, covers every zsh convention from `docs/CONVENTIONS.md` in summary form, defines "module"/"barrel"/"leaf" terminology, and pushes the TS-specific content down into its own scoped section pointing at the `code/*.instructions.md` files.
- [x] Keep as-is: `git-policy`, `documentation`, `agent-facing-markdown`, `todo-done-docs`, `file-naming`, `variable-naming`, `readme-standards`. — **Deviated on two, with reasoning**: `file-naming.instructions.md` and `variable-naming.instructions.md` turned out to be entirely TypeScript-specific on inspection (`index.ts` barrel rules, `.types.ts`/`.utils.ts` suffixes, a `@clack/prompts` import-alias rule `zconf` doesn't even use) — leaving them unscoped would present TS-only rules as general guidance in a zsh repo. Gave both the same `applyTo: "packages/zconf/**"` treatment as the `code/` files, with a note on `variable-naming`'s stale `@clack/prompts` reference (left rather than rewritten — the core "use full words" guidance is still sound, the example is just noise). `git-policy`, `documentation`, `agent-facing-markdown`, `todo-done-docs`, and `readme-standards` confirmed genuinely generic and left untouched.
- [x] Keep `picocolors-cli-styling` — now genuinely used by `zconf`. — Kept, scoped with the same `applyTo` frontmatter for consistency, and its example paths corrected: it referenced `utils/picocolors` (a path-alias form) and `src/utils/picocolors.ts`; the real file is `packages/zconf/src/utils/picocolors.ts`, imported as `../utils/picocolors.js` (relative, no alias configured).
- [x] Prune `AGENTS.md` "Learned Workspace Facts" of anything this refactor invalidates (`packages/node/`, `_zenvs/`, the Bitbucket remote line, the `apnaes` references). — `packages/node/` fact replaced with the real `packages/zconf/` one; the Bitbucket-only remote line corrected to name both remotes (`origin` = Bitbucket, `github` = the `finografic` GitHub remote `master` actually tracks) — worth stating explicitly while [P0.1](#p01--decide-and-execute-the-history-strategy) is open. No stale `_zenvs`/`apnaes` facts remained; both were already caught in earlier passes.
- [x] Update `.agents/handoff.md`: profile list, architecture paragraph, and open questions (most are answered by [Decisions](#decisions-needed-from-you)). — Kept current throughout this session already (updated after every phase); nothing further needed here.

### P7.4 — CI

- [x] `zsh -n` syntax check on every tracked `.zsh` (catches the `[[ $1 > "" ]]`-class bugs and anything a rename breaks). — Already in place (`zsh-syntax` job) since an earlier phase.
- [x] `shfmt --diff` on shell scripts, honouring the existing ignores (`lib/k.plugin.zsh` — moot once deleted). — New `shell-format` job, **scoped to `*.sh` only, not `*.zsh`**: shfmt parses bash/posix/mksh, not zsh's syntax extensions (`${(z)...}`, array flags, `(( ))` arithmetic used throughout this repo), so running it against `.zsh` files would fail to parse, not just report a diff — confirmed only 4 tracked `.sh` files exist and are genuinely bash. **Soft-fail** (`continue-on-error: true`): the repo's own settings disagree with themselves on tabs vs. spaces for shell files (`.editorconfig` defaults to spaces; `.vscode/settings.json`'s `[shellscript]` block configures `mkhl.shfmt` with `editor.insertSpaces: false`), and `shfmt` itself is blocked by this session's sandbox allowlist so its actual diff output could not be verified locally before committing — reporting rather than gating until a human confirms what it says and that ambiguity is resolved.
- [x] `oxlint`, `oxfmt --check`, `md-lint`, `commitlint`. — First three already wired (`lint-and-format` job). **`commitlint` added** as its own job: the husky `commit-msg` hook enforces this locally, but `--no-verify` bypasses it (how ~570 pre-rewrite commits got through) and a fork's PR never runs a hook it didn't install. Lints the single new commit on push, the full commit range on a PR.
- [x] `zconf doctor` and `zconf scan`. — Done in [P5.2](#p52--zconf-commands)'s CI wiring.
- [ ] **Container smoke matrix** — boot the config in `zsh:latest` with each profile forced (`ZENV=<name>`), assert exit 0, no stderr, and that a known function exists. This is the test that proves the refactor didn't break a profile you can't easily reach (server, android). — **Judged already satisfied, not implemented separately.** `tests/test-profile-boot.zsh` already does exactly this — boots all 8 profiles through the real load chain, asserts exit 0/no unexpected stderr/a known sentinel function per profile — and already runs in CI (`zsh-tests` job) on every push and PR. A first draft of a literal `container: zshusers/zsh:5.9` matrix job was written and then removed: it didn't actually route through the real boot chain (`core/env.zsh` → `determine-environment` → `core/profile.zsh` → the profile entry), making it a strictly weaker, redundant check next to the one that already exists — not worth shipping untested.
- [x] `pnpm test` for `packages/zconf` (Vitest). — Done in [P5.2](#p52--zconf-commands)'s CI wiring (`zconf` job).
- [x] Resolve the `package.json` ESM warning — add `"type": "module"` (verify no script fallout) or rename the TS config files. — Added `"type": "module"` to the root `package.json`. Verified no fallout: the warning is gone from `oxlint`/`oxfmt` output, `commitlint.config.mjs` is unaffected (already `.mjs`), no other root-level `.js`/`.cjs` file exists to break, and `packages/zconf` already had its own `"type": "module"`. Full re-verification after the change: lint, format:check, md-lint, doctor, scan, typecheck, and all 169 vitest tests still pass.

---

## Phase 8 — Optional polish

- [x] ~~`_zenvs/` → `profiles/` rename (D2)~~ — **promoted out of "optional" and moved to [P4.5](#p45--_zenvs--profiles-rename-d2-confirmed)**; the user confirmed it as a definite yes on 2026-07-26.
- [ ] `scripts/` grouping: `scripts/setup/`, `scripts/clean/`, `scripts/maintenance/`.
- [ ] `extras/` audit: `extras/music/` (djay/iCloud sync — genuinely personal; consider a separate repo), `extras/hardware/` (audio/display/keyboard — keep, it's interesting), `extras/hardware/logs/` (`fdisk.output`, two `keyboards-all*.man` dumps — delete).
- [ ] A `zdoctor` zsh-side health check (distinct from `zconf doctor`, which lints the _repo_): checks the _machine_ — missing tools, insecure compinit dirs, stale caches, firewall state. This is where the office firewall check and launchd verifications belong.
- [ ] Consider publishing the interesting bits (the profile loader, `zconf`) with a proper README so the repo is useful to read, not just to fork.

---

## Appendix A — Evidence log

Findings from the 2026-07-25 scan, combined with the earlier 2026-07-24 audit
(`PROJECT_ANALYSIS_AND_REFACTOR.md`, since folded in and deleted).

### Publish blockers

| Finding                                                    | Location                                                                                                                                                                      |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Real home / office / server IPv4 addresses                 | `core/env.zsh:51-55`, `packages/node/src/types.ts:32`, `packages/node/dist/detect-env.mjs*`, `tools/bin-*/install-binaries.sh:28`, `_zenvs/home-macos/home-macos.dev.zsh:219` |
| Work email set as global git identity on every shell       | `_zenvs/office-macos/office-macos.zsh:102`                                                                                                                                    |
| Personal email set as global git identity                  | `_zenvs/home-linux/home-linux.dev.zsh:51`, `lib/git/git.core.zsh:92`                                                                                                          |
| Repo's own `.git/config` overwritten on every office shell | `_zenvs/office-macos/office-macos.zsh:90-99`                                                                                                                                  |
| `gh auth login --with-token` on every interactive shell    | `main.zsh:153`                                                                                                                                                                |
| Employer secret variable names                             | `configs/.zshrc.OFFICE:1-5`                                                                                                                                                   |
| Personal identity in tracked git configs                   | `.gitconfig:10,15`, `configs/.gitconfig:6`                                                                                                                                    |
| Username-bearing p10k caches tracked (6 files)             | `themes/p10k/$HOME.cache/…justin.rankin…`                                                                                                                                     |
| Outbound `curl ipinfo.io` on every shell start             | `core/env.zsh:45,47`                                                                                                                                                          |
| 70 MB of third-party binaries, 66 MB unreferenced          | `tools/bin-arm64/`, `tools/bin-x86_64/`                                                                                                                                       |
| No `LICENSE`, no CI, no `CONTRIBUTING`                     | repo root, `.github/`                                                                                                                                                         |
| Full history already on the GitHub remote at `98c6b3f`     | `git ls-remote --heads github`                                                                                                                                                |

### Correctness bugs

| Bug                                                                              | Location                                                       |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Unreachable `IS_OFFICE` branch — `docker-dev` only reachable via `IS_DOCKER`     | `core/env.zsh:69`                                              |
| `function edit() { "$EDITOR $@"; }` — whole string treated as one command name   | `_zenvs/apnaes/apnaes.zsh:9`                                   |
| `alias vim="${EDITOR} $@"` — `$@` expands empty at definition time               | `main.zsh:92`                                                  |
| `export PATH=$PATH:$(which curl)` — appends a file, not a directory              | `_zenvs/apnaes/apnaes.paths.zsh:19`                            |
| `export env EXA_COLORS=…` — exports a variable named `env`                       | `lib/colors.zsh:5`                                             |
| `[[ $1 > "" ]]` used as a non-empty test (string comparison)                     | `_zenvs/office-macos/office-macos.zsh:68`, `apnaes.dev.zsh` ×6 |
| `alias logout="~."` — SSH escape sequence, not a command                         | `_zenvs/apnaes/apnaes.aliases.zsh:2-3`                         |
| `ssh -i …id_hostinger.pub` — public key passed as identity file                  | `_zenvs/home-macos/home-macos.dev.zsh:219`                     |
| `main.zsh` comment claims `typeset -U PATH` runs in bootstrap; it exists nowhere | `main.zsh:115`                                                 |
| Missing section `7.` in `main.zsh` numbering; sections already drifted           | `main.zsh:63`                                                  |

### Dead and duplicated code

| Item                                                                                    | Size                       |
| --------------------------------------------------------------------------------------- | -------------------------- |
| `lib/template-tool/` — 8 draft scripts, 2 palettes, 3 screenshots                       | ~900 lines                 |
| `lib/k.plugin.zsh` — vendored `k`, also loaded via Antidote                             | 593 lines                  |
| `lib/mongodb.zsh` — sourced nowhere                                                     | 73 lines                   |
| `lib/dev.jest.zsh` — employer-era, sourced only by home-macos                           | 91 lines                   |
| `packages/node/src/detect-env.ts` + `dist/` — reimplements `core/env.zsh`, used nowhere | ~200 lines + build output  |
| `packages/node/spinner.mjs` — stray root copy, differs from `dist/`                     | —                          |
| `_zenvs/apnaes/apnaes.paths-V1.zsh`, `-V2.zsh`                                          | 90 lines                   |
| `configs/.zshrc.{HOME,OFFICE,SERVER,DOCKER}` + `-orig` + 2 docker copies                | 8 copies of one file       |
| `.main.zsh.swp` (tracked vim swapfile), `plugins/.zsh_plugins.generated.*.zsh`          | 16 KB + generated          |
| Commented-out dead blocks (PM2, Docker autostart, `lsof` scan, iTerm, Loupedeck)        | ~120 lines across profiles |
| Duplicated Homebrew-prefix eval, Codex detection, nvm boot                              | 3 duplications             |

### Startup cost inventory (per interactive shell)

`node` ×2 (spinner incl. a deliberate 200 ms sleep, build-path) · `curl ipinfo.io` (network!) ·
`sw_vers` ×2 · `uname` ×3 · `hostname` · `brew shellenv` eval · `gh auth login` ·
`launchctl list` ×2 · `socketfilterfw` · `tmutil` · `lsof` · `neofetch`/`fastfetch` ·
plus ~7,300 lines of zsh parsed eagerly and file deletions from `lib/clean.zsh`.

> Baseline timings not captured in this pass — measuring is [P4.3](#p43--measure-it), and it
> gates the rest of Phase 4. Record real numbers here before optimising.

---

## Appendix B — Target tree

```
.zshrc-config/
├── bootstrap/              # ordered early init (+ typeset -U path, zcompile)
├── core/
│   ├── env.zsh             # detection only; no network, no IPs
│   ├── profile.zsh         # NEW — manifest loader + presets
│   ├── options.zsh  history.zsh  keybindings.zsh  locale.zsh
├── lib/                    # DEFINITIONS ONLY — sourcing is inert
│   ├── colors.zsh          # guarded; typeset -g, not export
│   ├── <domain>.zsh        # barrel  ─┐  git · node · clean · macos · dev
│   └── <domain>/           # leaves  ─┘  cli · paths · utils · splash
├── functions/              # NEW — autoloaded cold function bodies (fpath)
├── vendor/                 # nvm, pnpm — PATH/init only
├── profiles/               # was _zenvs/ (D2)
│   ├── home-macos/  office-macos/  home-linux/  server-linux/   # was apnaes
│   ├── docker-dev/  vscode/  codex/  android/
│   └── _presets/           # full · minimal · container
├── packages/zconf/         # TS: doctor · graph · scan · bench · new-profile
├── scripts/
│   ├── setup/              # install deps, install tools, configure git identity
│   ├── clean/  maintenance/
│   └── bench-startup.zsh
├── extras/                 # opt-in only: music/ hardware/ docker/
├── themes/  plugins/  configs/
├── docs/
│   ├── ARCHITECTURE.md  PROFILES.md  PERFORMANCE.md  CONVENTIONS.md
│   ├── benchmarks/  process/  todo/
├── .github/workflows/ci.yml
├── main.zsh  main-splash.zsh  update-config.zsh  .zshrc
└── LICENSE  README.md  AGENTS.md  CONTRIBUTING.md  SECURITY.md
```

Removed: `tools/bin-*` (70 MB) · `packages/node` · `lib/template-tool` · `lib/k.plugin.zsh` ·
`lib/mongodb.zsh` · `lib/dev.jest.zsh` · `configs/.zshrc.*` · tracked p10k caches ·
`.main.zsh.swp` · `package-lock.json`.

---

## Done

- 2026-07-26 — Phase 0 (Sonnet-tier subset): P0.3 (git-config mutation + `gh auth login` +
  redundant `NPM_TOKEN` awk parse removed; `scripts/setup/configure-git-identity.zsh` added),
  P0.4 (`tools/bin-{arm64,x86_64}` purged — 66 MB; `scripts/setup/install-tools.zsh` added;
  `lib/widgets.zsh` splash fallback simplified; `docs/OLLAMA.md` folded in), P0.5 (`LICENSE`,
  `SECURITY.md`, `CONTRIBUTING.md`, `package.json` fields, `.github/workflows/ci.yml`).
  **P0.1** (`[HUMAN]`) and **P0.2** (`[OPUS]`) are still open — see their sections above.
- 2026-07-26 — **P0.2** (`[OPUS]`): IPs/PII scrubbed. `IP_ADDRESSES` map and the
  `curl ipinfo.io` startup network call removed in favour of a lazy `myip`; SSH/deploy/NAS
  host details moved to `.env`; **a hardcoded SMB password** (`//touch:1234@…`) and a
  deploy alias carrying a real server IP were found and removed; tracked `.gitconfig`s,
  p10k username caches, `package-lock.json`, vim swapfile and `Icon\r` files untracked;
  `configs/.zshrc.OFFICE` + `_zenvs/docker-dev/configs/` deleted. **Zero IPv4 literals and
  zero personal identifiers remain** under the CI `secret-scan` pattern. Residual `apnaes`
  / `finografic` organisational names are owned by P2.1 and P7.3 and are deliberately not
  yet in the CI pattern.
- 2026-07-26 — **P4.1**, **P4.2**, and the `typeset -U path PATH` item from **P1.3**,
  pulled forward (untracking `packages/node/dist/` broke the two startup `node` calls that
  depended on it). Node is now entirely off the startup path; `packages/node` is deleted.
- 2026-07-26 — **P1.4** (`[OPUS]`): environment detection unified in new
  `core/detect.zsh` (`is-container`, `is-agent-shell`, `is-ide-shell`,
  `determine-environment`), sourced by both `bootstrap/` and `core/env.zsh`. The unreachable
  `IS_OFFICE` branch is fixed, three copies of the container check and two of the Codex
  check are collapsed, and `themes/` no longer re-derives `ZENV`. Two further bugs found by
  testing: the override now reads `ZENV_FORCE` (reading the exported `ZENV` broke detection
  in nested shells) and the function sets globals instead of printing (a command
  substitution discarded `ZENV_RESOLVED_BY`). `tests/test-detect.zsh` (22 cases) and
  `tests/test-lib-inert.zsh` now run in CI.
- 2026-07-26 — **P2.1** (Sonnet-tier): the two renames. `office-macos` genericised from 515
  lines/8 files to 118 lines/5 (deleted `dev.jest.zsh`, `parse-test-coverage.zsh`,
  `backups.zsh`, `hardware.zsh`); shared `lib/macos/macos.brew.zsh` extracted, pulling
  forward a P2.2 checkbox. `_zenvs/apnaes` → `_zenvs/server-linux` (7 files), `chown-*`
  trio → one `chown-to`, LSWS work isolated to an optional `server-linux.lsws.zsh` module
  (verified standalone), `edit`/`code` eval/quoting bugs fixed. The `apnaes`-specific
  `home-macos` repo aliases moved to the `REPO_ALIASES` `.env` pattern; the much larger
  `finografic` block in the same file is untouched by design (flagged for P7.1/P7.3, since
  migrating ~50 `@`-prefixed functions is a different, riskier job than this task's remit).
  `apnaes` added to the CI `secret-scan` pattern — zero references remain in tracked code.
  Two bugs found and fixed that weren't in the original audit: a dead `confirm()` that just
  echoed its input, and an `alias lr1=...` baking in `$(pwd)` at shell-start time.
- 2026-07-26 — **P2.2** (`[OPUS]`): declarative profile manifests. New `core/profile.zsh`
  provides `zenv-load` / `zenv-modules` / `zenv-features` / `zenv-opt-in` / `zenv-validate`,
  three presets, a module registry, and a canonical source order that makes declaration
  order irrelevant. The `node` module owns the whole nvm/pnpm boot, so the invariant that
  three profiles hand-rolled three ways is now unforgeable. All eight profiles converted;
  entry points are 32–58 lines. `main.zsh` shed ~60 lines of unconditional sourcing (its
  steps 10–13 are preset content now) and `vendor/index.zsh` is unused as a result.
  Deviations from the doc's sketch, both deliberate: `banner` is not a manifest feature (it
  would double-print, since the splash sources it — this actually _fixed_ a live
  double-banner in docker-dev), and `widgets`/`ghostty` are in no preset. Bug found by
  testing: the loader's local was named `modules`, a special read-only parameter once
  `zsh/parameter` is loaded (p10k loads it). Two new CI test files, 31 assertions total,
  including a boot test for every profile.
- 2026-07-26 — **P1.2** (`[OPUS]`): source-time side effects purged. `lib/clean.zsh` no
  longer deletes files on shell start — it defines `zclean … [--dry-run]`. The djay
  LaunchAgent checks, the firewall shell-out and the unconditional ghostty config copy are
  gone from the load path (`extras/music/djay-services.zsh`, new `zdoctor`, `-nt` staleness
  gate). `extras/` is no longer sourced from `main.zsh`. Four orphans deleted along the way
  (`dev.jest.zsh`, `mongodb.zsh`, `k.plugin.zsh`, `template-tool/`), closing most of
  **P3.1**. **Exit criteria verified**: every `lib/**.zsh` sources with zero output under
  `zsh -f`.
- 2026-07-26 — **P4.3** (Sonnet-tier, done out of order ahead of Phase 3 — see rationale in
  its section above): `scripts/bench-startup.zsh`, `ZSHRC_PROFILE=1` one-command `zprof`,
  a soft-fail CI ratio check, and a baseline recorded with a load-bearing caveat that it was
  captured in an AI-agent sandbox, not a real machine — full writeup in
  `docs/benchmarks/README.md`. Two real bugs found while building the tool, not in the
  audit: (1) `ZENV_FORCE` alone doesn't reach `vscode`/`codex`'s fast paths, since
  `main.zsh`'s early exits test real env signals, not `$ZENV` — a benchmark that didn't
  account for this would have quietly measured the slow path for exactly the profiles that
  most need to be fast; (2) a bare `local name` redeclaration inside a `{ ... } > file`
  block triggered zsh's `typeset` display-mode side effect and corrupted the first
  `--save` output with three stray `name=value` lines straight into the JSON.
- 2026-07-26 — **P4.4** (`[OPUS]`), most of it: removed the `lukechilds/zsh-nvm` plugin
  (nvm was loading twice per shell, −65% on full profiles); made `vendor/nvm.zsh` lazy
  (`nvm.sh` no longer sourced at startup — 2.5ms vs 584ms on the common path, the single
  biggest win of the phase); cached `pnpm --version` and eliminated `node --version` /
  `uname -m` / `hostname` shell-outs in the splash. Cumulative, sandbox, n=10, splash
  forced on: `codex` 1,340→63ms (now **meets** its 150ms budget), `vscode` 3,707→225ms,
  full profiles ~5,000ms→~550–780ms. One correction made live: the splash briefly defaulted
  to skipping nested/non-login shells, on the wrong assumption that was waste; the user
  caught it immediately (typing `zsh` is deliberate, the splash is the expected result) and
  it was reverted to on-by-default within the hour. Full detail and every verification in
  `docs/benchmarks/README.md`. **Not done**: `autoload`/`zcompile` — judged not worth
  chasing further, since the remaining gap is mostly the splash kept on by choice.
- 2026-07-26 — **P4.5**: `_zenvs/` → `profiles/` (D2, confirmed by the user, promoted out
  of Phase 8's optional list). `git mv` plus every `$ZENV_PATH`/`source` call site updated;
  zero `_zenvs` references remain outside `docs/todo/` history. Full test suite (63 cases)
  and a live shell boot both re-verified clean after the rename.
- 2026-07-26 — **P3.3** (Sonnet-tier), most of it: kebab-case/shebang/bracket-style items
  already resolved by earlier passes were confirmed clean; the `[[ ]]` sweep completed
  across `lib/`, `core/`, and `profiles/*` (deliberately excluding `extras/hardware/*` and
  `extras/music/*`, same scoping precedent as the P1.2 inertness sweep); `vendor/nvm.zsh`
  left untouched as vendored upstream code. **Three real bugs found doing this, not in the
  audit**: `_ga()`/`_gb()` in `git.commit.zsh`/`git.core.zsh` both used `[[ $1 > "" ]]`
  (string comparison, not a non-empty test) — fixed to `[[ -n "$1" ]]`; `lib/fzf.zsh` ran
  `git clone` unconditionally at source time on Linux whenever `~/.fzf` was missing, a real
  P1.2 violation invisible to macOS-only testing — moved into an explicit `install-fzf()`
  function. `profiles/android/android.banner.zsh`'s raw `\e[33m` escapes replaced with
  `${_y}${_bold}` to match the rest of the profile banners. `--dry-run` naming audited
  clean repo-wide. **Deliberately deferred, not attempted this batch**: `echo`/`echo -e` →
  `print` sweep (wide, behavior-neutral, own pass), confirm-prompt `(y/n)` label
  normalization (the inconsistency is intentional — destructive prompts have no default on
  purpose), `main.zsh` section-number cleanup (mid-churn from repeated restructuring), and
  wiring the two `normalize-*.py` scripts into `pnpm normalize`/CI (tooling, not a
  correctness fix). Full syntax check (all tracked `.zsh` files) + all 4 test suites +
  a live interactive-shell boot re-verified clean.
- 2026-07-26 — **P3.5** (Sonnet-tier): added `_ZSHRC_<NAME>_LOADED` guards to all 14
  remaining `lib/*.zsh` barrels, and explicit `source "$ZSHRC_ROOT/lib/colors.zsh"` lines
  to every leaf module (`lib/clean/*`, `lib/git/*`, `lib/cli/cli.listing.zsh`,
  `lib/dev/dev.workflow.zsh`, `lib/macos/macos.time-machine.zsh`, `lib/utils.zsh`,
  `lib/splash.zsh`) and profile file (banners + 3 dev-alias files) actually using
  `${_c}`-style vars without it. **Real bug found, not cosmetic**: `lib/git/git.tags.zsh`
  hand-rolled its own hardcoded-bold color palette instead of sourcing `lib/colors.zsh` —
  a genuine duplicated palette, exactly what this task's exit criteria targets. Deleted the
  local definitions; `_gtag`'s output now renders at the same weight as every other git
  helper (a real but purely cosmetic rendering change). Benchmarked after
  (`--zenv home-macos -n 15`: 563/591/692 ms min/p50/p95) — no measurable regression from
  the added guards, matching the <1ms prediction. Full test suite + live shell boot clean.
  Phase 3 exit criteria met.
- 2026-07-26 — **Phase 5** (`[OPUS]`): `packages/zconf` — TypeScript, tsdown, 169 vitest
  tests, picocolors via the shared `pc` helper, `tsc --noEmit` and type-aware oxlint clean.
  All six planned commands: `doctor`, `scan`, `graph`, `bench`, `normalize`, `new-profile`.
  The load graph is seeded from profile manifests as well as literal `source` lines, since
  `zenv-modules` resolves barrels through `${ZENV_MODULE_PATHS[$name]}` — a grep-based
  graph would call every barrel an orphan. **Six real bugs found by `doctor` on its first
  run**, all fixed: `alias lr="find $(pwd) …"` expanded at source time (baking the startup
  directory into the alias for its whole life, plus a process spawn per shell); `xcrun` and
  `which` shell-outs at source time in `dev.workflow.zsh` and `paths.linux.zsh` (the latter
  also appending a _binary_ to PATH, which holds directories, so the entry could never
  match); a missing `function` keyword; a snake_case function name; and four hardcoded
  `~/.zshrc-config` source paths. **Two bugs found in the Python normalisers while porting
  them**, both verified by running the originals: `normalize-functions.py` emitted
  `function thing(){` with no space, which would have restyled every definition in the
  repo; and `normalize-comment-blocks.py` injected a closing rule straight after a block
  title, shoving the prose out of multi-line `# NOTE:` blocks — it would have mangled 28
  files. The port fixes both, and both deviations are documented in the source. Running
  `zconf normalize` now changes exactly one file (`tests/test-lib-inert.zsh`, dashed rules
  → canonical) and is idempotent thereafter. `scan` was proved non-vacuous by planting a
  canary address and confirming it fired. **Not wired into `lint-staged`**: `doctor` and
  `scan` are whole-repo checks whose result does not depend on what is staged, so CI and a
  pre-push hook are the right homes. Still open in Phase 5: nothing — `docs/ARCHITECTURE.md`
  does not exist yet, so `zconf graph --write` has no target until [P1.1](#p11--write-the-contract-down)
  creates it (the command reports that clearly rather than failing obscurely).
- 2026-07-26 — **P6.1** (`[OPUS]`): `update-config.zsh` rewritten. Staging is now
  `git add -u` with untracked files listed **and sized** rather than swept in by `git add .`;
  every message path produces a commitlint-valid subject (so the hook stops being bypassed);
  rebase conflicts print recovery steps instead of dumping you mid-rebase; and a secret scan
  runs before every push, via `zconf scan` where Node exists and a dependency-free `git grep`
  where it does not. Stays pure zsh. New `tests/test-zupdate.zsh` — 23 cases, running
  against a throwaway repo with a local remote so it never touches this one — now in CI.
  **Three bugs found that the plan had not listed**: `~/bin/zupdate` forwarded no arguments
  at all (every flag and message silently dropped, so the whole new interface would have
  been unreachable — the launcher now lives at `bin/zupdate` and is symlinked); the old
  script pushed to a hardcoded `origin` while `master` actually tracks `github` (it now
  resolves the real upstream and prints the destination, which matters while
  [P0.1](#p01--decide-and-execute-the-history-strategy) is open); and the test suite caught a
  bug in the _new_ code — a commit whose push the scan blocked was stranded forever, because
  the next run saw a clean tree and returned without pushing. Fixed by sharing one
  `zu-push-if-ahead` step across both paths, with the regression test confirmed to fail when
  the fix is reverted. **P6.2 (history squash) remains open and is downstream of P0.1.**
