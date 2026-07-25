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

| #   | Decision                                                                                             | Options                                                                                              | Recommendation                                                                                                                                                                                                           |
| --- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| D1  | **How to publish given history is already on GitHub**                                                | (a) fresh public repo, clean history; (b) `git-filter-repo` + force-push existing; (c) publish as-is | **(a)** — see [P0.1](#p01--decide-and-execute-the-history-strategy). Force-pushing does not reliably remove blobs from GitHub, and 1,224 commits of `updated from: home-macos` add nothing for readers.                  |
| D2  | **`_zenvs/` naming**                                                                                 | keep `_zenvs/`; rename to `profiles/`                                                                | **`profiles/`** — self-documenting for outsiders; keep `$ZENV` as the variable name so churn is limited to path strings.                                                                                                 |
| D3  | **Profile loading model**                                                                            | keep per-profile hand-rolled `source` lists; move to a declarative manifest                          | **Manifest** ([P2.2](#p22--declarative-profile-manifests)) — the eight profiles are ~80% duplicate boilerplate today.                                                                                                    |
| D4  | **Vendored binaries (`tools/`, 70 MB)**                                                              | keep; keep only what's used; remove all + installer script                                           | **Remove all + installer** ([P0.4](#p04--purge-vendored-third-party-binaries)) — 13 of 15 are referenced nowhere, and redistributing them publicly is a licensing question you don't need.                               |
| D5  | **Node on the startup path**                                                                         | keep `spinner.mjs` + `build-path.mjs`; remove both                                                   | **Remove both** ([P4.1](#p41--remove-node-from-the-startup-path)) — two process spawns per shell for a fake progress delay and a job `typeset -U path` does natively.                                                    |
| D6  | **Where TypeScript lives**                                                                           | nowhere; startup helpers; a deliberate `zconf` dev toolkit                                           | **`zconf` toolkit** ([Phase 5](#phase-5--typescript-where-it-actually-earns-its-place)) — off the hot path, genuinely awkward in zsh, and it's the part that makes this repo interesting publicly.                       |
| D7  | **Colors: explicit or implicit source**                                                              | implicit (today); explicit `source` per file; **guarded** explicit                                   | **Guarded explicit** ([P3.5](#p35--colors-guarded-explicit-sourcing)) — you get the explicitness with ~zero cost. Answers your open question.                                                                            |
| D8  | **Source-time side effects** (`clean.zsh` auto-run, launchd checks, firewall check, `gh auth login`) | keep; gate behind flags; remove from load path entirely                                              | **Remove from load path** ([P1.2](#p12--purge-source-time-side-effects)) — becomes `zclean`, `zdoctor`. A config that mutates your machine on every shell is the #1 thing that scares people off a public dotfiles repo. |
| D9  | **IP-based environment detection**                                                                   | keep; remove                                                                                         | **Remove** ([P0.2](#p02--scrub-secrets-and-pii-from-the-working-tree)) — it hardcodes your home IP, breaks on any DHCP change, and `.env` flags already cover every real case.                                           |

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

- [ ] `core/env.zsh:51-55` — delete the `IP_ADDRESSES` map (real home / office / server IPv4 addresses).
- [ ] `core/env.zsh:71` — remove the `$IP == ${IP_ADDRESSES[APNAES]}` detection branch (D9). `.env` flags are sufficient.
- [ ] `core/env.zsh:44-48` — drop the unconditional `curl -s ipinfo.io/ip` fallback. It is a **network call on every shell start** that also leaks your IP to a third party. Make `$IP` lazy: a `myip` function, called on demand.
- [ ] `packages/node/src/types.ts:32` + `src/detect-env.ts` + all of `packages/node/dist/` — same IPs, plus committed build output. Deleted wholesale in [P4.2](#p42--delete-orphaned-node-utilities).
- [ ] `tools/bin-arm64/install-binaries.sh:28` and `tools/bin-x86_64/install-binaries.sh:28` — same server IP. Removed with [P0.4](#p04--purge-vendored-third-party-binaries).
- [ ] `_zenvs/office-macos/office-macos.zsh:101-102` — remove `git config --global user.name/user.email "justin.rankin@sage.com"`. See [P0.3](#p03--stop-mutating-global-git-config-and-authenticating-on-shell-start).
- [ ] `_zenvs/home-linux/home-linux.dev.zsh:51` and `lib/git/git.core.zsh:92` — same pattern with the personal address. Remove; identity is a machine-setup step, not a shell-start step.
- [ ] `_zenvs/home-macos/home-macos.dev.zsh:219` — `alias a="ssh -i ~/.ssh/id_hostinger.pub -p 22 apnaes@185.230.64.11"`. Move host/user/IP into `.env` (`SERVER_SSH_TARGET`) and reference the variable. Also note the alias points at a `.pub` file, which is the wrong half of the keypair — fix while you're there.
- [ ] Root `.gitconfig` and `configs/.gitconfig` — both tracked, both carry your email and the Bitbucket URL. Convert to `configs/gitconfig.example` with placeholders; untrack the real ones.
- [ ] `themes/p10k/$HOME.cache/p10k-*justin.rankin*` (6 tracked files, incl. `.zwc`) — machine-generated p10k caches with your username in the _path_. Untrack and gitignore `themes/p10k/**/*.cache/`, `*.zwc`.
- [ ] `configs/.zshrc.OFFICE:1-5` — `CYPRESS_SBS_USER_PASSWORD`, `CYPRESS_CF_ACCESS_CLIENT_SECRET`, `AWS_CONFIG_FILE`. Values are empty, but the _names_ disclose employer infrastructure. Delete the file ([P1.5](#p15--collapse-the-configs-reference-zshrc-files)).
- [ ] Grep sweep for anything left: `justin`, `rankin`, `sage`, `apnaes`, `finografic`, `hostinger`, `@gmail`, `Users/justin`, and an IPv4 regex. Everything that survives must be either a placeholder, an example, or in `.env`.
- [ ] Add `.DS_Store` cleanup (`git rm --cached`) and untrack `Icon\r`, `scripts/Icon\r`, `scripts/Icon?-_DJ-BAG`, `.main.zsh.swp`, `package-lock.json` (repo uses pnpm).

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

- [ ] Add `docs/ARCHITECTURE.md`: the layer table, the side-effect rule, `PATH` ownership, and a mermaid load-order diagram (`.zshrc` → `bootstrap/*` → `main.zsh` → `core/env` → `lib/*` → `profiles/$ZENV` → splash).
- [ ] Add "Architecture in 60 seconds" to `AGENTS.md` pointing at it.
- [ ] Auto-generate the diagram from the real source graph in [P5.2](#p52--zconf-commands) so it cannot drift.

### P1.2 — Purge source-time side effects

> **`[OPUS]`** — Load-order-sensitive: each side effect becomes a named function a profile opts into, without changing boot behavior. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Every item is "wrap in a function; let a profile or the user call it" (D8):

- [ ] `lib/clean.zsh:20-24` — **auto-runs `clean-downloads`, `clean-browsers`, `clean-caches-npm` on every full shell.** Deleting files on shell start is indefensible in a public repo. Replace with a `zclean [--all|--downloads|--browsers|--node] [--dry-run]` entry point. Optionally offer an opt-in `ZSHRC_AUTOCLEAN=1` honoured _once per day_ via a stamp file, not per shell.
- [ ] `_zenvs/home-macos/home-macos.zsh` + `office-macos.zsh` — the djay / djay-sync LaunchAgent blocks run `launchctl list | grep` (×2) and can `launchctl load` on every shell. Move to `extras/music/`, expose as `djay-services-check`, and call it from nothing by default.
- [ ] `office-macos.zsh:113-118` — the firewall `socketfilterfw --getglobalstate` shell-out. Move into `zdoctor`.
- [ ] `update-ghostty-config` is invoked at profile load in both macOS profiles. Make it explicit or gate it on the config file actually being stale.
- [ ] `main.zsh:147-150` — `extras/music/djay_icloud_sync.zsh` and `scripts/docker-cleanup.zsh` are sourced for **all** environments. Per the layer table, `extras/` is opt-in: move to `profiles/home-macos/`.
- [ ] Sweep for remaining top-level work: any tracked `.zsh` under `lib/` whose body has a bare command at column 0 that isn't a `source`, `export`, `alias`, `typeset`, `autoload`, or `zstyle`. Automate this as a `zconf doctor` lint ([P5.2](#p52--zconf-commands)) so it stays fixed.

### P1.3 — Single owner for `PATH`

- [ ] Document the rule in `docs/ARCHITECTURE.md`: `vendor/*` owns tool paths, `lib/paths/*` owns OS paths, `profiles/*/…paths.zsh` owns host paths. Nothing else appends.
- [ ] Add `typeset -U path PATH` **once**, early in `bootstrap/index.zsh`. This is what `main.zsh:115` already claims exists and what `build-path.mjs` was emulating.
- [ ] Remove ad-hoc appends from the wrong layers: `main.zsh:100-101` (homebrew coreutils/`hs`), `main.zsh:116`, `_zenvs/office-macos/office-macos.zsh:11` (Python 3.11 framework path), `:56-57` (`gen-test-summary`, `gen-todo-coverage`).
- [ ] `_zenvs/apnaes/apnaes.paths.zsh:19` — `export PATH=$PATH:$(which curl)` appends a _file_ path, not a directory. Delete.
- [ ] Delete `lib/paths.zsh:14-16` `flatten-path` (legacy Node call) once [P4.1](#p41--remove-node-from-the-startup-path) lands.

### P1.4 — Fix the environment-detection logic

> **`[OPUS]`** — Subtle correctness (unreachable branches, unified container/agent detection, explicit fallback semantics). PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

- [ ] `core/env.zsh:69` — `elif [[ $IS_OFFICE == true || $IS_DOCKER == true ]]` is **unreachable for `IS_OFFICE`** (handled one branch above), so `docker-dev` only ever resolves via `IS_DOCKER`. Reduce to `[[ $IS_DOCKER == true ]]`.
- [ ] Docker detection is inconsistent: `bootstrap/index.zsh:24` checks `/.dockerenv`, `$IN_DOCKER`, `$DOCKER_CONTAINER`, while `core/env.zsh` relies on `$IS_DOCKER`. Unify into one `is-container` helper used by both.
- [ ] Codex detection is duplicated verbatim in `bootstrap/index.zsh:10` and `main.zsh:38` (a four-clause condition). Extract to `core/env.zsh` as `is-agent-shell`.
- [ ] Quote and default all the flag tests (`[[ ${IS_HOME:-false} == true ]]`) — with `set -u`-style habits these are currently unquoted bare `$IS_HOME`.
- [ ] Move the whole detection block behind a single function with a documented precedence order, and make the fallback explicit rather than "default to `home-macos`" (a stranger's machine is not your home Mac — default to a generic profile).

### P1.5 — Collapse the `configs/` reference zshrc files

`configs/` holds five near-duplicate reference `.zshrc` files (`.HOME`, `.OFFICE`, `.SERVER`,
`.DOCKER`, `.zshrc-docker-orig`) plus a root `.zshrc` template, plus two more under
`_zenvs/docker-dev/configs/`. Eight copies of a three-line file.

- [ ] Keep exactly one: `.zshrc` at the repo root, as the reference template (already the documented convention).
- [ ] Delete `configs/.zshrc.{HOME,OFFICE,SERVER,DOCKER}`, `configs/.zshrc-docker-orig`, `_zenvs/docker-dev/configs/.zshrc-docker*`.
- [ ] Keep `configs/{ghostty.config,kitty.conf,.vimrc,plug.vim}` — those are real reference configs. Consolidate `.vimrc.V1`/`.vimrc.V2` to one and drop `ghostty.config.office` if it differs only in font size.
- [ ] Delete `_zenvs/docker-dev/configs/z` (stray file).

**Exit criteria:** `source`-ing any `lib/**.zsh` in a bare `zsh -f` produces no output and
touches no files; `docs/ARCHITECTURE.md` matches reality.

---

## Phase 2 — Profile system

### P2.1 — The two renames you asked for

**`office-macos` → generic office profile** (568 lines → target ~80):

- [ ] Remove all employer-specific content: the `SBS-` branch-prefix helper `_gb` (`office-macos.zsh:66-76`), `parse-coverage` / `gen-test-summary` / `gen-todo-coverage` PATH hacks, `office-macos.dev.jest.zsh`, `parse-test-coverage.zsh`, the Cypress/CF secrets in `configs/.zshrc.OFFICE`, and everything in [P0.3](#p03--stop-mutating-global-git-config-and-authenticating-on-shell-start).
- [ ] Replace the banner with a plain `OFFICE` figlet (`office-macos.banner.zsh`).
- [ ] Strip the commented-out dead blocks: PM2/launchd, Docker Desktop autostart, `lsof` security scan, iTerm2 integration, Loupedeck paths.
- [ ] Keep the genuinely reusable bones: dynamic Homebrew prefix detection (Apple Silicon vs Intel — this is good, and should be **promoted to a shared helper** used by every macOS profile rather than copy-pasted between home and office), and the file-set shape.
- [ ] End state: a populated-but-neutral "work Mac" profile that demonstrates the pattern — a few example aliases, a `paths.zsh` stub, a `TODO: populate per employer` marker. Not an empty skeleton (an empty profile teaches a reader nothing), not your old job.

**`apnaes` → `server-linux`** (307 lines → target ~120):

- [ ] `git mv _zenvs/apnaes profiles/server-linux`, rename all seven files, delete `apnaes.paths-V1.zsh` and `apnaes.paths-V2.zsh` (two stale versions of a live file).
- [ ] Genericise: `REPOS="/home/apnaes/repos"` → `${SERVER_REPOS:-$HOME/repos}`; `chown-apnaes` → drop; keep `chown-no` / `chown-ls` but rewrite them as one `chown-to <user>:<group>` with `--dry-run`.
- [ ] **Keep LSWS as an optional module**, per your note — `profiles/server-linux/server-linux.lsws.zsh`, sourced only when `/usr/local/lsws` exists. It holds: the `logs [std|acc|err] [--clear]` viewer, the `vh`/`lsws`/`ws` navigation aliases, and the `lu` (`sudo -u lsadm`) wrapper. Parameterise `/usr/local/lsws` as `${LSWS_ROOT:-/usr/local/lsws}`.
- [ ] Keep the PM2-under-`lsadm` wrappers but gate them on `command -v pm2`.
- [ ] Replace the `APNAES` ASCII banner with `SERVER`, and show hostname + distro + uptime instead of a figlet — more useful on a box you SSH into.
- [ ] Fix `apnaes.zsh:9` — `function edit() { "$EDITOR $@"; }` has the quotes wrong: it tries to execute the whole string as one command name. And `code() { eval "$(which jmate) $@"; }` should not `eval`.
- [ ] `apnaes.aliases.zsh:2-3` — `alias logout="~."` / `lo="~."` is an SSH escape sequence, not a command; it cannot work as an alias. Delete or document as a manual keystroke.
- [ ] Sweep the ghost references: `core/env.zsh:71-73`, `lib/node/nvm-autoload.zsh:13`, `lib/widgets.zsh:60,91`, `packages/node/src/types.ts:8`, `README.md`, `.agents/handoff.md`.
- [ ] **Do not** touch the `home-macos` client-side shortcuts (`REPOS_APNAES`, `alias apnaes=…`, `alias mono=…`) — different concern; they're just local repo paths. Move their values into `.env` via the existing `REPO_ALIASES` registry pattern, which is already documented in the README and is the right answer for a public repo.

### P2.2 — Declarative profile manifests

> **`[OPUS]`** — Genuine design, not transcription: the manifest loader, preset resolution, and the nvm-before-`lib/node.zsh` load-order invariant encoded so it can't be got wrong per-profile. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Today every `profiles/<name>/<name>.zsh` re-exports `ZSHRC_ROOT`, `ZENV_PATH`, `NVM`, then
hand-lists `source` lines. `vscode.zsh`, `codex.zsh`, and `docker-dev.zsh` additionally
hand-roll the entire nvm + pnpm + `lib/node.zsh` boot sequence, three slightly different ways.

- [ ] Add `core/profile.zsh` providing the loader and two helpers: `zenv-modules` (resolve names → `lib/` barrels) and `zenv-features` (resolve names → profile files).
- [ ] Each profile becomes a declaration:

  ```zsh
  # profiles/home-macos/home-macos.zsh
  ZENV_PRESET=full                      # full | minimal | container
  ZENV_MODULES=(git dev node llms paths macos)
  ZENV_FEATURES=(aliases dev paths banner backups)
  ZENV_OPT_IN=(music/backup-dj-crate)
  ```

- [ ] Add presets so the three minimal profiles stop diverging: `minimal` = colors + node + git + a `vcs_info` prompt; `container` = `minimal` minus macOS anything; `full` = everything.
- [ ] Extract the shared macOS Homebrew-prefix eval into `lib/macos/macos.brew.zsh` (currently duplicated in `home-macos.zsh:18-24` and `office-macos.zsh:19-27`).
- [ ] Preserve the **load-order invariant**: nvm must be initialised before `lib/node.zsh` (`nvm-autoload` silently no-ops otherwise). Encode it in the loader so it cannot be got wrong per-profile.
- [ ] Validate manifests in `zconf doctor` — unknown module name = error, not a silent skip.

### P2.3 — Profile inventory pass

- [ ] `android` — four files, Termux-only. Keep, but verify it still boots; it references `STORAGE_ROOT`/`PATH_ZSHRC` set only inside `determine-environment`.
- [ ] `docker-dev` — keep and simplify per your existing triage (§10 of the audit): generic Linux container profile, no work assumptions. Remove the shebang and top-level output (`docker-dev.zsh` is _sourced_), fold `extras/examples/` Dockerfiles down to one `Dockerfile` + one `docker-compose.yml`, and move them to `extras/docker/` so it's obvious they're runnable.
- [ ] `vscode` / `codex` — collapse onto the `minimal` preset. They differ meaningfully only in the prompt.
- [ ] `home-linux` — 4 files, currently the least-maintained profile. Either bring it up to the manifest standard as the _reference generic Linux desktop_ profile, or fold it into `server-linux` + a `linux-desktop` feature flag. Recommend keeping it: a public repo benefits from a non-macOS path that actually works.

**Exit criteria:** every profile is under 100 lines; adding a new host is a single 15-line
file; `zsh -n` and a container smoke test pass for all profiles.

---

## Phase 3 — `lib/` consolidation and dedupe

### P3.1 — Delete orphans

Nothing sources these (verified by basename grep across all tracked `.zsh`/`.md`):

- [ ] `lib/mongodb.zsh` (73 lines) — delete, or move to `extras/` if you still use MongoDB.
- [ ] `lib/template-tool/` — **8 files, ~900 lines** of `__tool.zsh`, `__tool_01.zsh`, `__tool-02-DRAFT.zsh`, `__tool-03-DRAFT.zsh`, `__tool-FINAL.zsh`, `__tool-accept.zsh`, `__TOOLS.zsh`, plus `__colors.zsh` _and_ `colors.zsh` (a third copy of the palette) and three screenshots. This is a scratch workspace. Extract whatever the "FINAL" version was actually for, or delete the directory outright. Either way it must not ship publicly as-is.
- [ ] `lib/k.plugin.zsh` (593 lines) — a vendored copy of `supercrabtree/k`, but `plugins/.zsh_plugins.txt` already loads `k` via Antidote from its own repo. Delete the vendored copy.
- [ ] `lib/dev.jest.zsh` (91 lines) — sourced only by `home-macos`, and it is employer-era Jest tooling. Delete or move to `extras/`.
- [ ] `themes/gallois-custom.zsh-theme`, `themes/restore-theme.zsh` — verify against `themes/default.theme.zsh`; delete whichever is superseded.
- [ ] `.main.zsh.swp` (16 KB tracked vim swapfile), `plugins/.zsh_plugins.generated.{linux,macos}.zsh` (generated output — `.gitignore` already ignores `.zsh_plugins.generated.zsh` but not these two variants).

That's roughly **1,700 lines and 66 MB** removed before a single behavioural change.

### P3.2 — Finish the domain barrels

The `vendor` / barrel / `lib/<domain>/` model is already half-built. Finish it:

| Domain    | Now                                                     | Target                                                                                                                                              |
| --------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `git`     | `lib/git.zsh` + `lib/git/` (7 leaves + `index.zsh`)     | Resolve the `git.zsh` vs `git/index.zsh` double-barrel — one entry point. Move `git.tags.README.md` to `docs/`.                                     |
| `node`    | `lib/node.zsh` + `lib/node/`                            | Done. Keep as the reference example.                                                                                                                |
| `clean`   | `lib/clean.zsh` + `lib/clean/`                          | Barrel is right; remove the auto-run ([P1.2](#p12--purge-source-time-side-effects)).                                                                |
| `macos`   | `lib/macos.zsh` + `lib/macos/{dock,time-machine,utils}` | Add `macos.brew.zsh` ([P2.2](#p22--declarative-profile-manifests)). Rename `utils` — a grab-bag named "utils" inside a domain folder attracts junk. |
| `dev`     | `lib/dev.zsh`, **340 lines**, the largest live module   | Split into `lib/dev/` — the npm/global-install helpers belong in `lib/node/`, the rest into `dev.workflow.zsh`.                                     |
| `cli`     | `lib/cli/{listing,navigation}` with no barrel           | Add `lib/cli.zsh`; `lib/common.zsh` currently sources the leaves directly.                                                                          |
| `utils`   | `lib/utils.zsh` + `lib/utils.disk.zsh`                  | Inconsistent with the `<domain>/` convention. Make it `lib/utils.zsh` + `lib/utils/disk.zsh`.                                                       |
| `paths`   | `lib/paths.zsh` + `lib/paths/{macos,linux,android}`     | Good. Just drop `flatten-path`.                                                                                                                     |
| `widgets` | `lib/widgets.zsh` (151 lines) + `lib/widgets.readme.md` | Splash-specific. Rename to `lib/splash.zsh` — it is only ever used by `main-splash.zsh` — and move the readme to `docs/`.                           |

- [ ] **Rule to codify:** identical basenames in two places is a smell (this is what made `pnpm` confusing until `vendor/pnpm-path.zsh` was renamed). Role-name the vendor/boot files; domain-name the UX modules.

### P3.3 — Consistency sweep

Apply the recorded conventions everywhere, ideally via a script + a `zconf doctor` check so it doesn't rot:

- [ ] `function` keyword + kebab-case names. Offenders include `_gb` (office), `_register_repo_aliases` (README example), `_pm2` (server).
- [ ] No shebang in sourced modules; a boxed `# NOTE:` header instead. Offenders: `main.zsh`, `bootstrap/index.zsh`, `vendor/index.zsh`, `core/env.zsh`, `update-config.zsh` (this one is executed, so it keeps its shebang), `_zenvs/vscode/vscode.zsh`, `codex.zsh`, `docker-dev.zsh`.
- [ ] `[[ ]]` not `[ ]`; quote all expansions. `office-macos.zsh` and `apnaes.dev.zsh` use bare `[ ... ]` and `[[ $1 > "" ]]` (a string _comparison_ used as a non-empty test — should be `[[ -n $1 ]]`).
- [ ] `print` or `printf` over `echo "\n..."` (the `echo -e` behaviour is not portable and several files rely on it).
- [ ] `${_c}` / `${_0}` from `lib/colors.zsh` — never local ANSI constants. Offenders: `lib/template-tool/colors.zsh` + `__colors.zsh` (deleted anyway), `extras/examples/run-docker-zsh.sh`, the `_zenvs/*/banner.zsh` files (raw `\e[32m`).
- [ ] `--dry-run` (not `--dry`) on every destructive helper, and confirm prompts with the default last: `(Y/n)` / `(n/Y)`.
- [ ] The two existing helpers — `scripts/normalize-comment-blocks.py` and `scripts/normalize-functions.py` — should be wired to `pnpm normalize` (or ported to `zconf`, [P5.2](#p52--zconf-commands)) and run in CI as a check.
- [ ] Section numbers in `main.zsh` comments (`1.`–`16.`) already drift — `7.` is missing entirely. Drop the numbers, keep the boxes.
- [ ] `main.zsh:92` — `alias vim="${EDITOR} $@"` — `$@` in an alias expands at _definition_ time to nothing. Just `alias vim="$EDITOR"`.
- [ ] Remove the commented-out duplicate `source` lines in `main.zsh` (`fzf.zsh:82`, `colors.zsh:113`).

### P3.4 — `lib/colors.zsh`: stop exporting

- [ ] 23 `export _X=` color vars leak into the environment of **every child process** (`env` output, subprocess memory, anything that dumps env in logs). They are only needed in-shell: change to `typeset -g`.
- [ ] Caveat first: verify nothing that runs as a _separate process_ depends on them — check `extras/music/*.zsh` (launchd jobs), `scripts/*.sh`, and `extras/examples/run-docker-zsh.sh`. Anything that does should source `lib/colors.zsh` itself.
- [ ] `lib/colors.zsh:5` — `export env EXA_COLORS=…` exports a variable literally named `env`. Fix to `export EXA_COLORS=…`.
- [ ] Consider `%F{…}`/`autoload colors` for prompt contexts, but raw escapes are fine for `print` output — not worth churning.

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

- [ ] Add the guard to `lib/colors.zsh`.
- [ ] Add the same guard idiom to every barrel (`lib/git.zsh`, `lib/node.zsh`, …) — it also makes re-sourcing your config for testing free.
- [ ] Add explicit `source` lines to the ~25 modules that reference color vars.
- [ ] Verify with the benchmark ([P4.3](#p43--measure-it)): measure before and after; if the delta exceeds 5 ms, revert to implicit and record the measurement in this doc. (Prediction: it will be under 1 ms.)

**Exit criteria:** `lib/` has no orphans, no duplicated palettes, one barrel per domain, and
`zconf doctor` passes clean.

---

## Phase 4 — Startup performance

### P4.1 — Remove Node from the startup path

Two `node` process spawns per interactive shell, ~30–80 ms each on macOS:

- [ ] `main.zsh:110` — `node packages/node/dist/spinner.mjs`. This is a **deliberate 200 ms delay to give a "busy" impression**. Delete it. If you want the visual, a pure-zsh spinner around the actual work is a few lines and costs nothing; a fake delay is 200 ms of your life per shell.
- [ ] `main.zsh:163` — `export PATH=$(node …/build-path.mjs)`. Replaced by `typeset -U path PATH` in `bootstrap/index.zsh` ([P1.3](#p13--single-owner-for-path)).
- [ ] `lib/paths.zsh:14-16` — `flatten-path`, the third caller of the same script. Delete.

### P4.2 — Delete orphaned Node utilities

- [ ] `packages/node/src/detect-env.ts` — a full TypeScript reimplementation of `core/env.zsh`'s `determine-environment`, referenced nowhere. Delete (D6: env detection stays in zsh — it must work before Node exists, e.g. on a fresh server).
- [ ] `packages/node/spinner.mjs` (stray root copy, differs from `dist/`) — delete.
- [ ] `packages/node/dist/**` — committed build output, and `.gitignore` already lists `dist/`. Untrack.
- [ ] With `spinner`, `build-path`, and `detect-env` all gone, `packages/node` is empty: delete it, along with `tsdown.config.ts`, its `tsconfig.json`, and the `build:node`/`typecheck:node` scripts. This also resolves the type-aware oxlint failures on unresolved `fs`/`process`/`child_process` — by deleting the dead code rather than repairing it.
- [ ] Keep `pnpm-workspace.yaml` **only** if [Phase 5](#phase-5--typescript-where-it-actually-earns-its-place) goes ahead (it will re-populate `packages/`). Otherwise flatten.

### P4.3 — Measure it

You cannot defend a budget you don't measure. This is a prerequisite for the rest of the phase.

- [ ] Add `scripts/bench-startup.zsh`: N cold `zsh -i -c exit` runs, report min/p50/p95, accept `ZENV=<profile>` to benchmark each profile, and diff against a committed baseline in `docs/benchmarks/`.
- [ ] Record the current baseline in this doc _before_ changing anything, so each subsequent phase can claim a real number.
- [ ] Add `bootstrap/00-profiling.zsh` documentation: how to get a `zprof` breakdown in one command (`ZSHRC_PROFILE=1 zsh -i -c exit`).
- [ ] Add the budget assertion to CI (soft-fail at first — CI runners are noisy; compare ratios between profiles rather than absolute ms).

### P4.4 — Structural speedups

> **`[OPUS]`** — Highest payoff, silent-failure footgun (`autoload`/`fpath` ordering, `zcompile` staleness, lazy shell-outs). One change per benchmark run. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Ordered by payoff-to-risk. Do them one at a time with a benchmark run between each.

- [ ] **`autoload` the cold functions.** ~7,300 lines of zsh are parsed on every shell, and most of it is functions you call rarely. Move rarely-used function bodies into a `functions/` directory on `fpath` with `autoload -Uz`, so startup registers a name instead of parsing a body. Best candidates: `lib/git/git.maintenance.zsh` (276 lines), `lib/git/git.commit.zsh` (230), `lib/git/git.tags.zsh` (147), `lib/git/git.stashes.zsh` (134), `lib/clean/*` (~350), `lib/llms.zsh`, `lib/utils/disk.zsh`. Aliases and completions must stay eager; function bodies need not be. This is the single biggest available win and it is the idiomatic zsh answer.
- [ ] **`zcompile` the hot path.** Compile `main.zsh`, `bootstrap/*`, and the eager barrels to `.zwc` with a staleness check. Gitignore the `.zwc` files (you already have stale committed ones under `themes/p10k/`).
- [ ] **Audit shell-outs on the load path.** Currently on every start: `sw_vers` ×2, `uname` ×3, `hostname`, `ipconfig`/`curl`, `brew shellenv` (an eval of a subprocess), `node` ×2, `gh auth login`, `launchctl list` ×2, `socketfilterfw`, plus the splash's `tmutil`, `lsof`, `neofetch`. Replace what you can with zsh builtins (`$OSTYPE`, `$CPUTYPE`, `${(%):-%m}` for hostname), make the rest lazy, and cache the genuinely slow ones (`brew shellenv` output) in `${XDG_CACHE_HOME}` keyed by brew version.
- [ ] **Make the splash opt-out.** `main-splash.zsh` runs `tmutil`, launchd queries, port scans, and a fetch tool on **every** shell. Gate on `ZSHRC_SPLASH=${ZSHRC_SPLASH:-1}` and skip it for non-login / nested shells (`[[ -o login ]]`). A stranger's first impression should not be a 300 ms banner.
- [ ] Re-run the benchmark; update `docs/benchmarks/`.

**Exit criteria:** zero `node` spawns at startup, a committed benchmark baseline, full profile
under 400 ms, minimal profiles under 150 ms.

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

- [ ] A single CLI, `zconf`, in `packages/zconf/` — TS, built with tsdown (already your toolchain), `bin` entry, invoked via `pnpm zconf …` and a thin `zconf` zsh wrapper for interactive use.
- [ ] Styling per your existing `.github/instructions/code/picocolors-cli-styling.instructions.md` — that instruction file finally has a real consumer.
- [ ] Vitest tests for all pure logic (source-graph parsing, manifest validation, benchmark stats). This is what gives the public repo credibility, and none of it can be tested sanely in zsh.
- [ ] Node typings configured properly this time (`@types/node`, `tsconfig` `"types"`), which closes the type-aware oxlint failures.

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

- [ ] Wire `doctor` + `scan` into CI and `lint-staged`.
- [ ] Explicitly **out of scope for TS**: environment detection, `PATH` building, the spinner, and `zupdate`. All must work without Node.

**Exit criteria:** `pnpm zconf doctor` is green, CI runs `doctor` + `scan`, and `packages/`
contains one real, tested package instead of aspirational scaffolding.

---

## Phase 6 — `zupdate` and git hygiene

### P6.1 — Rewrite `update-config.zsh`

> **`[OPUS]`** — Must be correct and fail-safe on a Node-less server: staging semantics, rebase-conflict path, pre-push `zconf scan`. PAUSE and suggest switching to Opus before starting. See [Model routing protocol](#model-routing-protocol).

Current flow: `fetch → add . → commit -m "updated from: $ZENV" → pull --rebase → push`. It
`git add .`s everything unseen and writes a commit message that **its own commitlint hook
rejects** — 570 commits of history prove the hook is being bypassed.

- [ ] `zupdate "<message>"` → uses it; if there's no conventional-commit type prefix, default to `chore:`.
- [ ] `zupdate` (no args) → open `$EDITOR` for a real message, like `git commit`. Never auto-generate silently.
- [ ] `zupdate --sync` → the only path that auto-messages, as `chore(sync): update from ${ZENV}` — valid per commitlint, and greppable for the later squash.
- [ ] `zupdate --dry-run` → show what would be staged, committed, and pushed. Nothing else.
- [ ] Show a `git status --short` summary and require confirmation before `git add .` (default `(Y/n)`), or better: stage tracked modifications only (`git add -u`) and list untracked files separately so a stray 50 MB file can't sneak in — which is how the binaries got committed in the first place.
- [ ] Keep `set -e`, `fetch` first, `pull --rebase`, and add a clean failure path when the rebase conflicts (currently `set -e` leaves you mid-rebase with no message).
- [ ] Add a pre-push `zconf scan` call so PII can never be pushed again.
- [ ] Stays **pure zsh** — it must work on a server with no Node.

### P6.2 — History

- [ ] If D1 = fresh repo: this is solved by construction. Nothing to do.
- [ ] If D1 = filter-repo: after [P6.1](#p61--rewrite-update-configzsh) makes sync commits identifiable, squash contiguous `chore(sync)` runs in one scripted pass. Tag `archive/pre-rewrite` first, do it from one machine while the others are idle, and re-clone everywhere afterwards.
- [ ] Either way: keep husky + commitlint. They were right; `zupdate` was wrong.

---

## Phase 7 — Documentation, agent rules, CI

### P7.1 — README for strangers

The current README is a good _inventory_ and a poor _pitch_. For a public repo it needs to
answer "why would I read this?" in the first screen.

- [ ] Lead with the idea: one config tree, N host profiles, auto-detected, measurably fast.
- [ ] A terminal screenshot or asciinema cast (you have `zsh.png` — replace it with something current).
- [ ] Startup numbers from the real benchmark, per profile. This is the credibility line.
- [ ] "Try it in 30 seconds" — the Docker one-liner, before any install instructions.
- [ ] "Make it yours" — `.env` flags, `zconf new-profile`, the `REPO_ALIASES` registry.
- [ ] Move the structure tree and load order to `docs/ARCHITECTURE.md`; link, don't inline.
- [ ] Fix what's now wrong: "eight host profiles … apnaes", the `packages/node` row, `tools/` binaries, and the `_register_repo_aliases` example (snake_case, violating your own convention).

### P7.2 — Docs set

- [ ] `docs/ARCHITECTURE.md` — layers, contract, generated mermaid diagram, `PATH` ownership.
- [ ] `docs/PROFILES.md` — the manifest reference, and a worked "add your own host" walkthrough.
- [ ] `docs/PERFORMANCE.md` — budget, how to profile, benchmark results.
- [ ] `docs/CONVENTIONS.md` — the zsh style rules from [P3.3](#p33--consistency-sweep), as the human-readable pair to `zconf doctor`.
- [ ] Fold in the scattered readmes: `lib/widgets.readme.md`, `lib/git/git.tags.README.md`, `lib/template-tool/README.tools.md`, `themes/README.md`, `tools/bin-*/INSTALLS.md`, `tools/bin-arm64/OLLAMA.md`, `extras/music/README*.md`.

### P7.3 — Agent rules, made relevant

- [ ] `.github/instructions/code/` is React/TypeScript boilerplate — `provider-context-patterns`, `typescript-patterns`, `modern-typescript-patterns` — in a zsh repo. Delete `provider-context-patterns` outright; keep the TS ones only if scoped to `packages/zconf/**` via frontmatter globs.
- [ ] `general.instructions.md` mandates strict TS / camelCase / PascalCase components. Rewrite as zsh-first: module load order, `function` + kebab-case, color vars, boxed comments, `--dry-run`, "modules" terminology, the `.env`/profile model, and the side-effect rule.
- [ ] Keep as-is: `git-policy`, `documentation`, `agent-facing-markdown`, `todo-done-docs`, `file-naming`, `variable-naming`, `readme-standards`.
- [ ] Keep `picocolors-cli-styling` — now genuinely used by `zconf`.
- [ ] Prune `AGENTS.md` "Learned Workspace Facts" of anything this refactor invalidates (`packages/node/`, `_zenvs/`, the Bitbucket remote line, the `apnaes` references).
- [ ] Update `.agents/handoff.md`: profile list, architecture paragraph, and open questions (most are answered by [Decisions](#decisions-needed-from-you)).

### P7.4 — CI

- [ ] `zsh -n` syntax check on every tracked `.zsh` (catches the `[[ $1 > "" ]]`-class bugs and anything a rename breaks).
- [ ] `shfmt --diff` on shell scripts, honouring the existing ignores (`lib/k.plugin.zsh` — moot once deleted).
- [ ] `oxlint`, `oxfmt --check`, `md-lint`, `commitlint`.
- [ ] `zconf doctor` and `zconf scan`.
- [ ] **Container smoke matrix** — boot the config in `zsh:latest` with each profile forced (`ZENV=<name>`), assert exit 0, no stderr, and that a known function exists. This is the test that proves the refactor didn't break a profile you can't easily reach (server, android).
- [ ] `pnpm test` for `packages/zconf` (Vitest).
- [ ] Resolve the `package.json` ESM warning — add `"type": "module"` (verify no script fallout) or rename the TS config files.

---

## Phase 8 — Optional polish

- [ ] `_zenvs/` → `profiles/` rename (D2), with a one-release compat shim if you want to be gentle to your other machines.
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
