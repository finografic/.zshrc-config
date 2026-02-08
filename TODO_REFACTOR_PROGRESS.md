# ZSHRC-CONFIG REFACTOR PROGRESS

> **IMPORTANT FOR AI AGENTS**: This file tracks the refactor progress. Update this file as tasks are completed. When starting a new chat, reference this file to understand current state.

---

## COMPLETED PHASES

### Phase 1: Fix Errors + Minimal .zshrc + Bootstrap (DONE)

- [x] Fixed Antidote plugin loading errors (was sourcing plugin list directly instead of through antidote bundle)
- [x] Created `bootstrap/` directory with modular loading:
  - `bootstrap/index.zsh` - Main loader (sources all bootstrap files in order)
  - `bootstrap/00-profiling.zsh` - zprof, compfix settings
  - `bootstrap/01-antidote.zsh` - Antidote install check + load
  - `bootstrap/02-plugins.zsh` - Plugin bundle with caching
  - `bootstrap/03-compinit.zsh` - Completion system with daily cache
  - `bootstrap/04-prompt.zsh` - p10k config loading
- [x] Created minimal `~/.zshrc` (30 lines) that sources bootstrap + main.zsh
- [x] Synced project `.zshrc` with system `~/.zshrc`
- [x] Created `plugins/.zsh_plugins.txt` (plugin list for antidote)
- [x] Fixed compinit order (must be BEFORE plugins)
- [x] Fixed p10k instant prompt warning (set `POWERLEVEL9K_INSTANT_PROMPT=quiet` in ~/.p10k.zsh)
- [x] Fixed grep .env error in main-get-env.zsh (was using relative path)
- [x] Added "Initializing zsh..." message BEFORE p10k instant prompt
- [x] Removed spinner.js (was adding 600ms delay)
- [x] Loaded colors.zsh module early in bootstrap

### Phase 3: Bootstrap Order (DONE)

- [x] Correct order implemented: profiling → compinit → antidote → plugins → prompt → main.zsh
- [x] Docker/VSCode early exits preserved in main.zsh

---

## COMPLETED (continued)

### Phase 2: Reorganize File Structure (DONE)

- [x] Created `core/` directory with: env.zsh, options.zsh, history.zsh, keybindings.zsh, locale.zsh
- [x] Created `vendor/` directory with: index.zsh, pnpm.zsh, nvm.zsh
- [x] Created `lib/git/` directory, moved all git modules, created index.zsh
- [x] Updated `lib/git.zsh` as thin wrapper to `lib/git/index.zsh`
- [x] Moved history loading to bootstrap/00-profiling.zsh (early as in original)
- [x] Updated main.zsh to use new paths
- [x] Updated _zenvs/docker-container/docker-container.zsh
- [x] Deleted old files: main-get-env.zsh, main-zsh-config.zsh, main-vendor.zsh, lib/history.zsh, lib/keybindings.zsh, lib/nvm.zsh, lib/git.*.zsh

---

## IN PROGRESS

_None_

---

## PENDING PHASES

### Phase 3-VSCode: Optimize VSCode Early Exit (AUTO-FRIENDLY)

**File**: `_zenvs/vscode/vscode.zsh`

**Goal**: Fast startup (<200ms) for VSCode integrated terminals with essential features

**Should include**:

- Theme/prompt (p10k or minimal)
- Core aliases (ls, cd, git shortcuts)
- Colors module
- PATH basics
- Git integration

**Should skip**:

- Splash screen / banner
- Hardware detection
- System info collection
- Time Machine widget
- Docker widget
- LaunchAgent checks
- `ports()` output

**Steps**:

1. Review current `_zenvs/vscode/vscode.zsh`
2. Ensure it sources essential modules only
3. Test in VSCode terminal
4. Measure startup time with `time zsh -i -c exit`

---

### Phase 4: TypeScript/Node Migration (OPUS RECOMMENDED)

**Goal**: Move complex logic to TypeScript for type safety, linting, testability

**Candidates for TS/Node**:

| Current                  | New TS Module            | Benefit                   |
| ------------------------ | ------------------------ | ------------------------- |
| `main-get-env.zsh` logic | `node/src/detect-env.ts` | Enums, exhaustive checks  |
| `flatten_PATH()`         | `node/src/build-path.ts` | Dedup, validate paths     |
| `lib/spinner.js`         | `node/src/spinner.ts`    | Already JS, convert to TS |
| Splash data collection   | `node/src/splash.ts`     | Cache system info         |

**Keep in Shell** (not for TS):

- Aliases, keybindings, widgets
- `source` statements, exports
- zsh options, prompt config

**Steps**:

1. Create `node/` directory with package.json, tsconfig.json
2. Set up tsx for direct TS execution
3. Migrate detect-env first (simplest)
4. Wire into shell via `eval "$(node dist/detect-env.js)"`
5. Test and measure impact

---

### Phase 5: Caching (AUTO-FRIENDLY after setup)

**Goal**: Cache expensive operations to speed up startup

**Cache location**: `~/.cache/zshrc-config/`

**What to cache**:

- System info (hostname, IP, OS) - refresh daily
- compinit - refresh weekly (already done in 03-compinit.zsh)
- Plugin bundle - refresh on plugins.txt change (already done in 02-plugins.zsh)
- Hardware detection - refresh on boot

**Steps**:

1. Create cache directory structure
2. Add cache age checking functions
3. Implement for system info collection
4. Update widgets to use cached data

---

### Phase 6: Code Cleanup (AUTO-FRIENDLY)

**Goal**: Remove duplication, improve code quality

**Tasks**:

- [ ] Remove duplicate `.env` loading (currently in main-get-env.zsh AND lib/utils.zsh)
- [ ] Remove duplicate pnpm setup (if any remain)
- [ ] Consolidate PATH modifications to one location
- [ ] Use `typeset -U PATH` once, early
- [ ] Replace `grep | awk` chains with single commands
- [ ] Clean up unused files (old versions, backups)

---

### Phase 7: Documentation (AUTO-FRIENDLY)

**Goal**: Update README and documentation

**Tasks**:

- [ ] Update README.md with new structure
- [ ] Document bootstrap sequence
- [ ] Document multi-system setup process
- [ ] Add troubleshooting section
- [ ] Clean up old TODO files

---

## FILES REFERENCE

### New Structure (after refactor)

```
~/.zshrc                          # Minimal: instant prompt → bootstrap → main
~/.zshrc-config/
├── .zshrc                        # Reference copy (keep synced with ~/.zshrc)
├── main.zsh                      # Orchestrator
├── bootstrap/
│   ├── index.zsh                 # Bootstrap loader
│   ├── 00-profiling.zsh
│   ├── 01-antidote.zsh
│   ├── 02-plugins.zsh
│   ├── 03-compinit.zsh
│   └── 04-prompt.zsh
├── core/                         # (Phase 2 - DONE)
│   ├── env.zsh
│   ├── options.zsh
│   ├── history.zsh
│   ├── keybindings.zsh
│   └── locale.zsh
├── vendor/                       # (Phase 2 - DONE)
│   ├── index.zsh
│   ├── pnpm.zsh
│   └── nvm.zsh
├── lib/
│   ├── colors.zsh
│   ├── utils.zsh
│   ├── common.zsh
│   ├── dev.zsh
│   ├── fzf.zsh
│   ├── widgets.zsh
│   └── git/                      # (Phase 2 - DONE)
├── _zenvs/                       # Environment-specific configs
├── themes/
├── plugins/
├── scripts/
├── music/
└── node/                         # (Phase 4 - TODO)
```

---

## MODEL RECOMMENDATIONS

| Phase                     | Complexity | Recommended Model               |
| ------------------------- | ---------- | ------------------------------- |
| Phase 2: File restructure | Medium     | AUTO (clear steps, file moves)  |
| Phase 3-VSCode            | Low        | AUTO (simple edits)             |
| Phase 4: TS Migration     | High       | OPUS (architecture decisions)   |
| Phase 5: Caching          | Medium     | AUTO after Opus designs pattern |
| Phase 6: Cleanup          | Low        | AUTO (straightforward)          |
| Phase 7: Docs             | Low        | AUTO (writing)                  |

---

## NOTES FOR CONTINUING

1. Always test in a new terminal after changes
2. Keep `~/.zshrc` and `~/.zshrc-config/.zshrc` in sync
3. The `~/.p10k.zsh` file has `POWERLEVEL9K_INSTANT_PROMPT=quiet` set
4. Bootstrap order is critical: compinit → antidote → plugins
5. VSCode/Docker early exits in main.zsh skip the heavy splash screen

---

_Last updated: Feb 8, 2026 - Phase 2 complete_
