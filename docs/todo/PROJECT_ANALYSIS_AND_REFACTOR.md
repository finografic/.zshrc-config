# Project Analysis & Refactor Plan — zshrc-config

_Analysis date: 2026-07-24 · Branch: `master` · 1,214 commits since 2018-12-18_

This document surveys the current state of `zshrc-config` and proposes a staged
refactor. It maps directly onto the goals you outlined: code cleanup/dedupe,
consistent patterns, a minimal `office-macos` skeleton, AI-agent friendliness,
the oxc tooling decision, an improved `zupdate`, and the optional folder/TS/git
history work.

Findings are ordered by **impact and safety**. The "Refactor Plan" at the end
sequences them into phases.

---

## TL;DR — the five things that matter most

1. **Broken tooling is wired into commit hooks.** `lint-staged` calls
   `oxlint -c oxlint.config.ts`, but **oxlint is not installed and the config
   file does not exist**. `pnpm format` calls `dprint fmt` but there is **no
   `dprint.json`**. AGENTS.md documents `oxfmt` and `pnpm format:fix`, **neither
   of which exists**. This is the "oxc linting/formatting" you asked about — the
   verdict is **remove it**, it does not apply.
2. **A node subprocess dedupes `PATH` that nothing actually deduped.** `main.zsh`
   claims `typeset -U PATH` runs in bootstrap — **it does not exist anywhere in
   the repo**. Instead `build-path.mjs` spawns Node on every shell start to do a
   job one zsh line does natively. Two Node processes launch per shell start
   (`spinner.mjs` + `build-path.mjs`), adding startup latency.
3. **`detect-env.ts` is fully orphaned.** It re-implements `core/env.zsh`'s
   `determine-environment` in TypeScript but is referenced nowhere. Dead code
   with a compiled `dist/` + sourcemaps.
4. **`office-macos` mutates global git config on every shell.** It runs
   `git config --global user.email "justin.rankin@sage.com"` and copies
   `.gitconfig` over `.git/config` at every office launch — side-effecting and
   partly destructive. Cleaning this to a minimal skeleton (your request) also
   removes a real footgun.
5. **AI guidance is generic TS-project boilerplate.** `AGENTS.md` and
   `.github/instructions/**` describe React/TypeScript conventions (strict mode,
   PascalCase components, provider/context patterns, tree-shaking) that mostly
   do not apply to a zsh dotfiles repo. Agents are being pointed at the wrong
   rules.

---

## 1. Broken / orphaned tooling (fix or remove first)

These fail _today_ or are dead weight. Highest priority because they degrade
every commit and confuse both humans and agents.

| Item                                                                        | State                                                                                                                  | Evidence                                                                          |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `oxlint` lint-staged hook                                                   | **Broken** — binary not installed, `oxlint.config.ts` missing                                                          | `package.json` `lint-staged`; `node_modules/.bin` has no `oxlint`; no config file |
| `pnpm format` / `format.check`                                              | **Broken** — `dprint` installed but no `dprint.json`                                                                   | `dprint` present in `.bin`; no `dprint.json` in repo                              |
| `oxfmt`, `pnpm format:fix`                                                  | **Phantom** — documented, never existed                                                                                | `AGENTS.md` L68–71                                                                |
| `packages/node/src/detect-env.ts` (+ `dist/detect-env.*`, `.map`, `.d.mts`) | **Orphaned** — never sourced/imported                                                                                  | `grep detect-env` → 0 hits outside its own files                                  |
| `packages/node/spinner.mjs` (stray copy at package root)                    | **Duplicate** — differs from `dist/spinner.mjs`, unused                                                                | `main.zsh` sources `dist/spinner.mjs` only                                        |
| `build-path.mjs` PATH dedup                                                 | **Redundant** — `typeset -U PATH` does this natively; the claimed bootstrap `typeset -U` **does not exist**            | `main.zsh:115` comment vs. repo-wide grep = 0 hits                                |
| Duplicate `build-path.mjs` call                                             | Legacy invocation in `lib/utils.zsh:16` overlaps `main.zsh:163`                                                        | both run the same script                                                          |
| commitlint vs. `zupdate`                                                    | **Contradiction** — commit-msg hook enforces conventional commits, `zupdate` writes `"updated from: X"` (invalid type) | `commitlint.config.mjs` `type-enum`; `update-config.zsh:20`                       |

**Recommendation:**

- Delete the `lint-staged` block and remove `oxlint` from the mental model
  entirely (it was never installed).
- For `dprint`: either add a minimal `dprint.json` **or** drop the
  `format`/`format.check` scripts and the `dprint` dep. Given only 4 TS source
  files, **dropping it** is the leaner choice; keep formatting an editor concern.
- Delete `detect-env.ts` + its build artifacts (see §7 for the alternative:
  promoting it to the single source of truth — pick one, don't leave both).
- Delete stray `packages/node/spinner.mjs`.
- Replace `build-path.mjs` with `typeset -U path PATH` in bootstrap; remove the
  Node call from `main.zsh:163` and the legacy one in `lib/utils.zsh`.
- Resolve the commitlint/`zupdate` contradiction in §5.

---

## 2. Code cleanup, dedupe, dead code

### `main.zsh`

- Commented-out `# source` lines: `fzf.zsh` (L82, already sourced L61),
  `colors.zsh` (L113, already L59), `common.zsh` (L121, already L60). Remove.
- `alias vim="${EDITOR} $@"` — `$@` in an alias definition is a no-op/footgun;
  this should be a function or a plain alias.
- Section numbering (1–15) in comments is nice for humans but drifts as sections
  move. Keep the boxed style; consider dropping the numbers.

### `core/env.zsh`

- `determine-environment` has an **unreachable branch**:
  `elif [[ $IS_OFFICE == true || $IS_DOCKER == true ]]` — `IS_OFFICE == true`
  already returned `office-macos` one branch above, so docker is only reachable
  via `IS_DOCKER`. Simplify to `[[ $IS_DOCKER == true ]]`.
- OS/arch/IP detection here is **duplicated** by `detect-env.ts` (§7).

### Repo cruft (tracked or clutter)

- 10+ `.DS_Store` files, plus `Icon`, `scripts/Icon`, `scripts/Icon?-_DJ-BAG`.
  Add `.DS_Store` and `Icon?` to `.gitignore`, then `git rm --cached` any that
  are tracked.
- Commented-out dead blocks in `office-macos.zsh` (PM2 startup, docker
  auto-start, `lsof` security scan, iTerm integration) — remove as part of the
  skeleton reset (§3).

### Consistency pass (your "consistent patterns" goal)

- Standardize on the learned preferences already recorded in `AGENTS.md`:
  `function` keyword + kebab-case names, color vars from `lib/colors.zsh`, boxed
  78-char comment separators. `office-macos.zsh` uses snake_case-ish `_gb`, bare
  `[ ... ]` tests, and `echo "\n..."`; home files are more consistent. Do a
  lint-style sweep (the two `scripts/normalize-*.py` helpers already exist for
  comment/function normalization — wire them into a `make`/`pnpm` task).

---

## 3. `office-macos` → minimal skeleton (keep, but clean)

Per your instruction: **leave the environment, clean it to a minimal, ready-to-
populate skeleton.** Today it is 570 lines across 8 files carrying real,
stale, Sage-specific content.

**What to remove / neutralize:**

- **`git config --global user.email "justin.rankin@sage.com"`** and the
  `.gitconfig` → `.git/config` copy (`office-macos.zsh:90–103`). This mutates
  global git identity and repo config on every office shell. Do **not** carry
  this into the skeleton — it is the single riskiest line in the repo.
- Sage-specific `SBS-` branch prefix helper `_gb`.
- djay LaunchAgent load checks, firewall/security scans, `parse-coverage` /
  `gen-test-summary` PATH hacks, PM2/Loupedeck commented blocks.

**Target skeleton** (mirror `home-macos`'s file set, stubbed):

```
_zenvs/office-macos/
  office-macos.zsh          # sources the others; minimal, no side effects
  office-macos.aliases.zsh  # empty stub w/ header
  office-macos.dev.zsh      # empty stub
  office-macos.paths.zsh    # empty stub (home has one; office doesn't — add it)
  office-macos.banner.zsh   # minimal banner
  office-macos.hardware.zsh # empty stub
  office-macos.backups.zsh  # empty stub
```

Drop `office-macos.dev.jest.zsh` and `parse-test-coverage.zsh` from the profile
(move to `extras/` if you want to keep them for reference). Each stub gets the
canonical boxed header and a `# TODO: populate for new office profile` marker.

---

## 4. AI-agent friendliness

The repo already invests heavily in agent docs (`AGENTS.md`, `CLAUDE.md`,
`.github/instructions/**`, `.cursor/rules/**`, `.agents/**`,
`docs/process/PROJECT_MEMORY_MODEL.md`). The problem is **relevance and
duplication**, not absence.

**Issues:**

- `.github/instructions/**` is generic TS/React guidance
  (`typescript-patterns`, `modern-typescript-patterns`,
  `provider-context-patterns`, `picocolors-cli-styling`,
  `general.instructions.md` mandating strict TS, camelCase, PascalCase
  components). **~90% does not apply** to a zsh config repo and actively
  misdirects agents.
- **Fragmented planning docs**: `TODO_REFACTOR.md` (root), `docs/todo/ROADMAP.md`,
  `docs/MODELS_FOR_REFACTOR.md`, `.agents/handoff.md`, `.agents/memory.md`, and
  now this file. AGENTS.md also references `TODO_REFACTOR_PROGRESS.md` (learned
  pref) which doesn't exist. An agent has no single source of truth.
- AGENTS.md references rule files as if canonical, but their content targets a
  different kind of project.

**Recommendation:**

- Rewrite `.github/instructions/**` to zsh-first rules: module load order,
  `function` + kebab-case, color-var usage, boxed comment style, `--dry-run`
  convention, "modules" terminology, the multi-system `.env`/`_zenvs` model.
  Keep only the genuinely shared docs (markdown/table conventions, git policy).
- **Consolidate planning into one file** (e.g. this doc + a single
  `docs/todo/ROADMAP.md`). Retire `TODO_REFACTOR.md`, `MODELS_FOR_REFACTOR.md`,
  and the phantom `TODO_REFACTOR_PROGRESS.md` reference.
- Keep `AGENTS.md` as the entry point (CLAUDE.md → AGENTS.md is already good),
  but prune its "Learned User Preferences" to what's still true and add a short
  "Architecture in 60 seconds" map (bootstrap → main → env → zenv).
- Add a top-level **load-order diagram** (mermaid) so agents grok the boot
  sequence without reading every file.

---

## 5. `zupdate` — from blind sync to proper commits

**Current** (`zupdate` → `update-config.zsh`): `fetch → add . → commit -m
"updated from: $ZENV" → pull --rebase → push`. This predates your use of proper
commit messages and **violates** the repo's own commitlint config.

**Goal:** quick updates _with_ correct, conventional commit messages, while
keeping a fast path for genuinely mechanical multi-system syncs.

**Proposed design** (`update-config.zsh` rewrite):

- `zupdate "<message>"` → commits with the given message; validate/encourage a
  conventional prefix. If no type prefix is given, default to `chore:`.
- `zupdate` (no arg) → open `$EDITOR` for a real message (like `git commit`),
  **not** an auto-message.
- `zupdate --sync` → the _only_ path that uses the old auto-message, explicitly
  labeled `chore(sync): update from ${ZENV}` so it passes commitlint and is
  greppable/squashable later.
- Keep the safe `fetch → commit → pull --rebase → push` flow and `set -e`.
- Add `--dry-run` (per your CLI preference) to preview without pushing.
- Decide: keep husky+commitlint (recommended, now that messages are real) so the
  hook and `zupdate` agree instead of contradict.

This directly enables the git-history goal (§8): once sync commits are typed
`chore(sync)`, they're trivial to identify and squash in bulk.

---

## 6. Folder restructure (optional)

The current layout is reasonable. Targeted tweaks only:

- **`packages/` / `tools/` / `extras/` are near-empty scaffolding** for a
  monorepo that never materialized (`packages/node` is the only real package;
  `tools/bin-*` and several `extras/*` dirs are empty). Either populate the
  intent or flatten: move `packages/node` → `node/` and drop the empty
  `pnpm-workspace.yaml`/monorepo framing unless you plan to grow it.
- **`scripts/` mixes** install, cleanup, docker, and Python normalizers. Group:
  `scripts/setup/`, `scripts/clean/`, `scripts/maintenance/`.
- **`docs/`** has `DOCKER.md` + `DOCKER_IMPLEMENTATION.md` (merge), and
  `MODELS_FOR_REFACTOR.md` (retire — see §4).
- **`lib/` is actively layering** (not “leave alone”) — see **§9** for the
  emerging `vendor` / `lib/node` / `lib/clean` model and remaining sweep ideas.
  Still worth splitting the large `lib/dev.zsh` by concern if it keeps growing.

Net: **flatten the aspirational monorepo scaffolding** rather than add structure;
**do** keep consolidating `lib/` into domain barrels.

---

## 7. TypeScript — keep, wire in, or drop?

Only **2 of 4** TS utilities are actually used (`spinner`, `build-path`);
`detect-env` is orphaned and `build-path` is redundant (§1).

**Decision matrix:**

| Utility         | Used?              | Recommendation                                                                                                                              |
| --------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `spinner.ts`    | Yes                | **Keep** — genuine visual value, cheap. (Or replace with a pure-zsh spinner to drop the Node dependency at startup entirely.)               |
| `build-path.ts` | Yes, but redundant | **Drop** → `typeset -U path PATH` in bootstrap. Removes one Node spawn per shell start.                                                     |
| `detect-env.ts` | No                 | **Pick one:** delete it, _or_ promote it to the single source of truth and delete zsh's `determine-environment` duplicate. Don't keep both. |
| `types.ts`      | supports above     | Follows whatever survives.                                                                                                                  |

**Guidance:** TypeScript earns its place when logic is complex, testable, and
runs off the hot path. Shell startup is the hot path — every Node spawn costs
~30–80ms. Prefer pure-zsh for anything that runs on _every_ interactive shell,
and reserve TS for tooling you invoke deliberately (build scripts, generators).
Given that, the honest end-state is likely **spinner in zsh, no Node at
startup** — which also lets you delete the whole `packages/node` build pipeline
(`tsdown`, `tsx`, `dist/`). That folds into §5 of the existing `TODO_REFACTOR.md`
caching goal from a different angle: don't cache the Node call, eliminate it.

---

## 8. Git history cleanup (optional, do last)

**Reality:** 1,214 commits; the dominant messages are noise —
`updated from: home-macos` (235), `Commit all changes` (224),
`updated from: office-macos` (111), plus merge commits (~70) and other
auto-messages. Well over half the history is mechanical sync noise.

**Options, safest → most invasive:**

1. **Do nothing to history; fix forward** (recommended default). Ship §5 so new
   commits are meaningful. History is a single-remote Bitbucket personal repo,
   so the cost of _not_ rewriting is low.
2. **Reword only recent commits** (`git rebase -i` on the last N) — improve the
   messages you'll actually revisit, leave ancient history alone.
3. **Squash by era** — collapse runs of `updated from: *` between meaningful
   changes. Automatable once §5 tags syncs as `chore(sync)`: group and squash
   contiguous `chore(sync)` runs with a scripted interactive rebase or
   `git-filter-repo`.
4. **Full rewrite** — not recommended. 8 years of hashes change, any clone/CI
   breaks, and the payoff on a personal repo is cosmetic.

**Cautions:** any rewrite = force-push. Because you push from multiple machines,
every other machine's clone must be re-cloned or hard-reset afterward, or the
next `zupdate` will conflict badly. If you rewrite, do it once, from one machine,
when the others are idle, and re-clone them. **Archive a tag
(`git tag pre-rewrite-archive`) first.**

**Recommendation:** Option 1 now, Option 3 later once §5 makes sync commits
mechanically identifiable. Skip Option 4.

---

## Refactor Plan (phased)

Sequenced so each phase is independently shippable and low-risk before the risky
bits.

### Phase 0 — Quick wins (low risk, high clarity)

- Remove `.DS_Store`/`Icon*`, update `.gitignore`.
- Delete `detect-env.ts` + artifacts and stray `packages/node/spinner.mjs`.
- Remove commented-out `# source` lines and the `vim` alias footgun in `main.zsh`.
- Fix the unreachable docker branch in `determine-environment`.

### Phase 1 — Tooling truth (fix the broken pipeline)

# NOTE: MAY BE DONE ALREADY, OR NOT APPLY

- Remove the `oxlint` lint-staged block; drop `oxlint`/`oxfmt` from all docs.
- Decide dprint: add `dprint.json` **or** remove `format` scripts + dep (lean: remove).
- Replace `build-path.mjs` with `typeset -U path PATH`; remove both Node calls.
- Align AGENTS.md with reality (no phantom scripts/tools).

### Phase 2 — `office-macos` skeleton

- Reduce to stubbed skeleton mirroring `home-macos` (§3).
- Remove the global git-config mutation and `.gitconfig` copy permanently.

### Phase 3 — `zupdate` rewrite

- Implement message-aware `update-config.zsh` with `--sync`/`--dry-run` (§5).
- Reconcile with commitlint.

### Phase 4 — Agent friendliness

- Rewrite `.github/instructions/**` to zsh-first rules; prune generic TS docs.
- Consolidate planning docs to one; add the load-order diagram.

### Phase 5 — Structure & TS (optional)

- Flatten aspirational monorepo scaffolding; decide spinner-in-zsh vs. keep Node.
- Group `scripts/`; merge docker docs.

### Phase 6 — Git history (optional, last)

- Fix-forward now; scripted `chore(sync)` squash later; archive tag before any rewrite.

---

## 9. Lib layering & module hygiene (observations, 2026-07)

_Loose notes from recent cleanup sessions — not a sequenced plan. Use later when
building a proper structured plan. Lots of organization remaining across the
tree; these are patterns that worked and places that still hurt._

### Emerging layering (keep this mental model)

| Layer                                | Role                                                                                         | Examples                                                                     |
| ------------------------------------ | -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `vendor/`                            | **Boot / PATH / init only** — early, minimal shells                                          | `vendor/nvm.zsh`, `vendor/pnpm-path.zsh`                                     |
| `lib/<domain>.zsh` + `lib/<domain>/` | **Barrel + helpers** — define functions/aliases, no surprise side effects when possible      | `lib/node.zsh` → `nvm-autoload.zsh`, `pnpm.zsh`; `lib/clean.zsh` → `clean/*` |
| `lib/clean/`                         | **Teardown / prune** — separate from everyday UX                                             | `clean.node.zsh`, `clean.ides.zsh`, …                                        |
| `_zenvs/*`                           | **Host profile** — paths, aliases, banners; should _source_ shared lib, not re-own Node boot | still duplicates nvm/pnpm wiring in vscode/codex                             |

**Rule of thumb that clarified `pnpm` confusion:** same basename in two places
is a smell. Prefer role-named vendor files (`pnpm-path.zsh`) vs UX modules
(`lib/node/pnpm.zsh`).

**Load-order invariant:** anything that needs `nvm.sh` (e.g. `nvm-autoload`)
must run _after_ nvm is loaded. Barrel (`lib/node.zsh`) is the right home;
`vendor/nvm.zsh` should not also source the same hook (double `chpwd`).

### Already moved in this direction (partial — don’t re-plan as greenfield)

- `lib/clean/` + `lib/clean.zsh` barrel: downloads / browsers / ides / node teardown
  wrapped as callable functions; aliases `_cnm` / `_cnpm` / `vsclean`.
- `lib/node/` + `lib/node.zsh` barrel: `nvm-autoload` + `pn` / `pnr` / `npmls`;
  stripped out of `aliases.common.zsh`.
- `vendor/pnpm.zsh` → `vendor/pnpm-path.zsh` (PATH/`PNPM_HOME` only).
- IDE cleaner: shebang removed, `exit` → `return`, uses `lib/colors.zsh`.
- Dead `msg()` helper removed from `lib/utils.zsh` + call sites.
- `space` collapsed to one OS-aware function in `lib/utils.disk.zsh`.
- Vendored `k` plugin renamed `.zsh` + EditorConfig `ignore` (shfmt ≠ full zsh).

### Still messy / good candidates for the same treatment

**A. Side effects on source (shell-start “surprise”)**

- `lib/clean.zsh` still **auto-runs** `clean-downloads`, `clean-browsers`,
  `clean-caches-npm` on every full shell. Decide: keep as intentional hygiene,
  gate behind a flag, or move to an explicit `zclean` / login-only hook.
- Audit other modules for top-level work that isn’t behind a function
  (historically downloads/browsers/node-caches; may remain elsewhere).

**B. Domain barrels that don’t exist yet**

- `lib/dev.zsh` — large mix (npm view/global install, `alias i=pnpm install`,
  jest-adjacent helpers, misc). Candidates: peel Node UX leftovers into
  `lib/node/`, leave “dev workflow” or split `lib/dev/` .
- `lib/git/` — already a folder; confirm a single `lib/git.zsh` barrel and that
  nothing sources leaf files ad hoc.
- `lib/macos/` vs `lib/macos.utils.zsh` — dock / time-machine vs grab-bag;
  unify naming (`lib/macos.zsh` barrel + `lib/macos/*`).
- `lib/paths/` vs `_zenvs/*/…paths.zsh` — OS path soup vs profile paths; document
  which owns `$PATH` mutations to avoid triple-append of nvm bins.
  dumping domain helpers back in.
- `lib/template-tool/`, `lib/widgets.zsh`, `extras/` — clarify “sourced by
  default” vs “opt-in”; several paths are half-orphaned.

**C. Minimal shells duplicate boot story**

- `_zenvs/vscode/vscode.zsh` and `_zenvs/codex/codex.zsh` hand-roll
  `NVM_DIR` + `nvm.sh` + `lib/node.zsh` + `vendor/pnpm-path.zsh`. Works, but
  drifts from `vendor/index.zsh`. Suggestion: thin shared snippet e.g.
  `vendor/node-minimal.zsh` (“load nvm + pnpm-path + lib/node”) used by
  vscode/codex/docker-dev, _or_ document the intentional divergence.
- `docker-dev` optional NVM: must keep **nvm before** `lib/node.zsh` (autoload
  no-ops if sourced too early). Easy to break when reordering.
- Docs still mention dead `lib/nvm.zsh` in places (`docs/DOCKER*.md`,
  `extras/examples/DOCKER_QUICKSTART.md`) — refresh to `vendor/nvm.zsh` /
  `lib/node.zsh`.

**D. Module shape conventions (apply on touch)**

- Sourced modules: **no shebang**; logic in `function kebab-case`; top boxed
  `NOTE:` describing usage.
- Prefer `lib/colors.zsh` (`${_c}` / `${_0}`) over local ANSI constants.
- Confirm prompts: capital letter = default; if “default is always last”, use
  `(n/Y)` / `(Y/n)` consistently (squash prompt already flipped).
- Prefer `--dry-run` naming on CLIs/helpers.
- shfmt/editorconfig: ignore heavy/vendored zsh (`lib/k.plugin.zsh` pattern);
  keep `shfmt.formatIgnored: false` so ignores are respected.

**E. Doc / planning duplication**

- Root `PROJECT_ANALYSIS_AND_REFACTOR.md` **and**
  `docs/todo/PROJECT_ANALYSIS_AND_REFACTOR.md` — pick one canonical path
  (prefer `docs/todo/`) and delete or stub the other.
- Same theme as §4: too many parallel “refactor truth” files.

**F. REMOVE `_zenvs/apnaes/`**

- Drop the remote-server profile entirely: delete `_zenvs/apnaes/` (and any
  generated/profile wiring that only exists for it).
- Sweep remaining `apnaes` / `ZENV == apnaes` special cases so the tree doesn’t
  keep a ghost environment:
  - `core/env.zsh` (`determine-environment` → `apnaes`)
  - `vendor/nvm.zsh` (`NODE_VERSION_PREFERRED` case)
  - `lib/node/nvm-autoload.zsh` (skip path-var sync when `ZENV == apnaes`)
  - `lib/widgets.zsh` (Linux/apnaes branches)
  - README / `.agents/handoff.md` profile lists
- **Do not confuse** with home-macos aliases that `cd`/`ssh` to apnaes _repos_
  (`REPOS_APNAES`, `alias apnaes=…`, `alias a=ssh …`) — those are client-side
  shortcuts and can stay unless you decide to retire that project entirely.

### Suggested direction when you write the real plan

1. **Codify the three-layer rule** (vendor boot / lib domain barrels / clean
   teardown) in AGENTS.md “Architecture in 60 seconds”.
2. **One domain at a time** — finish git + macos barrels before inventing new
   top-level folders; avoid a big-bang `lib/` rewrite.
3. **Kill source-time side effects** or make them explicit and documented.
4. **Deduplicate minimal-shell Node boot** (vscode/codex/docker).
5. **Sweep stale paths** in docker docs and any remaining `lib/nvm*` references.
6. **Remove `_zenvs/apnaes/`** + env/nvm/widget special cases (§9F).
7. Leave `packages/node` / TS startup decisions to §7 — orthogonal to zsh
   module layering.

---

## Open questions for you

1. **dprint:** keep formatting (add config) or drop entirely? (Recommend drop —
   tiny TS surface.)
2. **Spinner:** worth a Node spawn on every shell, or convert to pure zsh and
   delete the whole `packages/node` build chain?
3. **detect-env:** delete, or promote to single source of truth for env
   detection (removing the zsh duplicate)?
4. **Git history:** fix-forward only, or schedule a one-time `chore(sync)` squash
   pass after Phase 3?
5. **Monorepo scaffolding:** grow into it, or flatten `packages/node` → `node/`?
6. **Clean auto-run on shell start:** keep downloads/browsers/npm prune every
   launch, or make cleanup opt-in / login-only?
7. **Minimal shells:** shared `vendor/node-minimal.zsh`, or keep vscode/codex
   hand-rolled?
8. **`_zenvs/apnaes/`:** confirm delete profile only (keep home-macos ssh/repo
   aliases), or retire apnaes shortcuts everywhere?
