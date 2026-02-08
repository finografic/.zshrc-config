# zshrc-config Full Refactor Plan

## Current State Analysis

**CRITICAL: Current Broken State**

The shell currently shows errors on startup:

```
/Users/REDACTED/.zshrc-config/.zsh_plugins.zsh:2: no such file or directory: ohmyzsh/ohmyzsh
/Users/REDACTED/.zshrc-config/.zsh_plugins.zsh:7: no such file or directory: romkatv/powerlevel10k
... (many more plugin errors)
```

**Root Cause:** The `.zsh_plugins.zsh` file contains Antidote bundle specifications (plugin identifiers like `ohmyzsh/ohmyzsh`), but `main.zsh` line 28 does `source "$ZSHRC_ROOT/.zsh_plugins.zsh"` which treats them as file paths instead of passing them through Antidote's bundle command.

**The Fix:** Plugin definitions must be processed by Antidote, not sourced directly:

```zsh
# WRONG (current):
source "$ZSHRC_ROOT/.zsh_plugins.zsh"

# CORRECT:
antidote bundle < "$ZSHRC_ROOT/plugins/.zsh_plugins.txt" > "$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"
source "$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"
```

------

**Key Issues Identified:**

- **BROKEN:** Plugin file sourced directly instead of through Antidote
- Duplicate loading: p10k loaded in both `.zshrc` and `main.zsh`
- Duplicate logic: pnpm PATH setup in both `.zshrc-BACKUP` and `main.zsh`
- NVM loaded twice (backup shows two different locations)
- `.env` loading happens in both `main-get-env.zsh` and `lib/utils.zsh`
- `compinit` in `.zshrc` but plugins may require it later
- Slow startup: spinner.js adds 600ms, `node --version`/`npm --version` calls, `lsof` for ports, `tmutil` snapshots
- No caching for expensive operations (hardware detection, system info)
- Inconsistent PATH construction across multiple files

**Current Bootstrap Order (from `.zshrc`):**

1. zprof, history, compinit
2. Antidote check/install
3. Antidote plugins + generate
4. p10k config
5. p10k instant prompt
6. `main.zsh` (which loads everything else)
7. Installer-managed blocks (pnpm, nvm)

------

## Phase 1: Fix Current Errors + Minimal .zshrc + Bootstrap Scaffold

**Goal:** Fix the broken shell, create a clean immutable `.zshrc`, and move all logic into the project.

### Step 1.0: FIX CURRENT ERRORS (First Priority)

The plugin system is broken. Fix by:

1. **Rename** `.zsh_plugins.zsh` → `plugins/.zsh_plugins.txt` (it's a plugin list, not a script)
2. **Create proper Antidote loading** in `bootstrap/01-plugins.zsh`:

```zsh
# bootstrap/01-plugins.zsh
PLUGIN_LIST="$ZSHRC_ROOT/plugins/.zsh_plugins.txt"
PLUGIN_CACHE="$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"

# Only regenerate if source changed
if [[ ! -f "$PLUGIN_CACHE" || "$PLUGIN_LIST" -nt "$PLUGIN_CACHE" ]]; then
  antidote bundle < "$PLUGIN_LIST" > "$PLUGIN_CACHE"
fi

source "$PLUGIN_CACHE"
```

1. **Remove** the direct `source "$ZSHRC_ROOT/.zsh_plugins.zsh"` from `main.zsh`

### What moves from `.zshrc-BACKUP` to this project:

- Antidote installation check → `bootstrap/00-antidote.zsh`
- Antidote plugin loading → `bootstrap/01-plugins.zsh`
- p10k instant prompt → `bootstrap/02-prompt.zsh` (MUST be early)
- compinit → `bootstrap/03-compinit.zsh`
- Vendor blocks (pnpm, nvm) → `vendor/pnpm.zsh`, `vendor/nvm.zsh`

### New `.zshrc` (target):

```zsh
# p10k instant prompt (must be first)
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# Bootstrap
source "$HOME/.zshrc-config/main.zsh"
```

### New directory: `bootstrap/`

- `00-antidote.zsh` - Antidote installation + loading
- `01-plugins.zsh` - Plugin bundle generation (with static cache)
- `02-prompt.zsh` - p10k theme loading
- `03-compinit.zsh` - Completion system init

------

## Phase 2: Restructure File Organization

### Proposed directory structure:

```
.zshrc-config/
├── main.zsh                    # Entry point (orchestrator only)
├── bootstrap/                  # Early initialization (order-sensitive)
│   ├── 00-antidote.zsh
│   ├── 01-plugins.zsh
│   ├── 02-prompt.zsh
│   └── 03-compinit.zsh
├── core/                       # Core zsh config (always loaded)
│   ├── env.zsh                 # Environment detection (from main-get-env.zsh)
│   ├── options.zsh             # Zsh options (from main-zsh-config.zsh)
│   ├── history.zsh             # (move from lib/)
│   ├── keybindings.zsh         # (move from lib/)
│   └── locale.zsh              # Language/locale settings
├── vendor/                     # Package manager configs
│   ├── pnpm.zsh
│   ├── nvm.zsh
│   └── homebrew.zsh
├── lib/                        # Utilities (loaded on-demand or conditionally)
│   ├── colors.zsh
│   ├── utils.zsh
│   ├── git/                    # Consolidate git.*.zsh files
│   └── ...
├── node/                       # TypeScript/Node utilities (NEW)
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── detect-env.ts       # Environment detection
│   │   ├── build-path.ts       # PATH construction + dedup
│   │   ├── splash.ts           # System info collection
│   │   └── cache.ts            # Cache management
│   └── dist/                   # Compiled JS
├── _zenvs/                     # Environment-specific (unchanged)
├── themes/                     # Prompt themes (unchanged)
└── plugins/                    # Plugin definitions (unchanged)
```

------

## Phase 3: Improved Bootstrap Order

**Optimal loading sequence:**

```
1. [INSTANT] p10k instant prompt (in .zshrc, before anything)
2. [EARLY]   Antidote + plugins (static bundle, no regeneration)
3. [EARLY]   Completion system (compinit with caching)
4. [CORE]    Environment detection (ZENV, OS_NAME, etc.)
5. [CORE]    Zsh options + history + keybindings
6. [CORE]    Locale settings
7. [GATE]    Docker/VSCode early exit (return 0) ← See details below
8. [VENDOR]  Homebrew, pnpm, nvm (conditional)
9. [LIB]     Colors, utils, common aliases
10. [ENV]    Environment-specific config (_zenvs/$ZENV/)
11. [LATE]   Splash screen (with caching)
12. [FINAL]  PATH cleanup (single call)
```

### VSCode Terminal Early Exit (Step 7 Detail)

VSCode integrated terminals should load a minimal but functional config for speed:

```zsh
# In main.zsh, after core loading:
if [[ "$TERM_PROGRAM" = "vscode" ]]; then
  source "$ZSHRC_ROOT/_zenvs/vscode/vscode.zsh"
  return 0  # Early exit
fi
```

**What VSCode terminals SHOULD get:**

- Theme/prompt (p10k or minimal)
- Core aliases (ls, git shortcuts, navigation)
- Environment vars (EDITOR, PATH basics)
- Git integration
- Node/pnpm/nvm (for development)
- Colors

**What VSCode terminals should SKIP:**

- Splash screen / banner
- Hardware detection
- System info collection
- Spinner animation
- Time Machine widget
- Docker widget
- LaunchAgent checks
- `ports()` output

**VSCode config file** (`_zenvs/vscode/vscode.zsh`) should be:

- Self-contained with all essentials
- Fast (target: <200ms total startup)
- Include: colors, core aliases, git aliases, PATH setup
- Exclude: anything that calls external commands unnecessarily

------

## Phase 4: TypeScript/Node/JS Migration

**Philosophy:** Shell orchestrates, Node computes. Move logic that benefits from:

- Type safety and linting
- Complex string/data manipulation
- Caching logic
- Testability

### High-value candidates for TS/Node:

| Current Location                | New TS Module            | Benefit                                    |
| ------------------------------- | ------------------------ | ------------------------------------------ |
| `main-get-env.zsh`              | `node/src/detect-env.ts` | Enums, exhaustive checks, testable         |
| `flatten_PATH()`                | `node/src/build-path.ts` | Dedup, validate paths exist, order control |
| `lib/spinner.js`                | `node/src/spinner.ts`    | Already JS, just convert to TS             |
| `lib/widgets.zsh` (splash data) | `node/src/splash.ts`     | Cache system info, structured output       |
| PORT detection (`lsof` parsing) | `node/src/ports.ts`      | Faster parsing, JSON output                |

### Keep in Shell (not suitable for TS):

- Aliases
- Keybindings/widgets
- `source` statements
- Environment exports
- zsh options
- Prompt configuration

### Node project setup (`node/`):

- `tsx` for direct TS execution (already in devDependencies)
- Output: `KEY=VALUE` exports or JSON
- Shell consumes via: `eval "$(node dist/detect-env.js)"`

------

## Phase 5: Performance Optimizations

### 5.1 Caching Strategy

Create `~/.cache/zshrc-config/` for:

- System info (hostname, IP, OS version) - refresh daily
- Plugin bundle - refresh on plugins.txt change
- Hardware detection - refresh on boot
- compinit cache - refresh weekly

**Cache invalidation:**

```zsh
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zshrc-config"
CACHE_FILE="$CACHE_DIR/sysinfo.json"
CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
CACHE_MAX=86400  # 24 hours

if [[ ! -f "$CACHE_FILE" || $CACHE_AGE -gt $CACHE_MAX ]]; then
  node "$ZSHRC_ROOT/node/dist/collect-sysinfo.js" > "$CACHE_FILE"
fi
```

### 5.2 Lazy Loading

- NVM: Use `zsh-nvm` lazy loading (already in plugins)
- Heavy utilities: Load on first use via autoload
- Docker widget: Skip if Docker not running

### 5.3 Conditional Execution

- Skip spinner in non-interactive shells
- Skip splash screen in VSCode/Docker
- Skip hardware detection if cached
- Skip `ports()` call - make it on-demand only

### 5.4 Specific Fixes

| Issue                              | Fix                         | Impact |
| ---------------------------------- | --------------------------- | ------ |
| `spinner.js` 600ms delay           | Remove or reduce to 100ms   | -500ms |
| `node --version` / `npm --version` | Cache in sysinfo            | -200ms |
| `lsof` for ports                   | Make on-demand, not startup | -300ms |
| `tmutil listlocalsnapshots`        | Cache daily                 | -150ms |
| Antidote bundle regeneration       | Static loading              | -200ms |

------

## Phase 6: Code Cleanup

### Remove duplication:

- Single `.env` loading (in `core/env.zsh` only)
- Single p10k loading location
- Single pnpm/nvm setup
- Consolidate PATH modifications to one location

### Consolidate files:

- Merge `git.*.zsh` files into `lib/git/` module with index
- Merge `paths.*.zsh` into environment-specific configs
- Remove unused theme files

### Improve code:

- Use `typeset -U PATH` once, early
- Replace `grep | awk` chains with single commands
- Use zsh built-ins where possible

------

## Phase 7: Future Suggestions

### Quick Wins (after refactor):

- Add `zsh-defer` plugin for lazy loading heavy modules
- Use `zsh-bench` for precise profiling
- Add health check command: `zshrc-health`
- Auto-update mechanism for plugins

### Longer Term:

- Rust binaries for truly hot paths (if needed)
- Web dashboard for configuration management
- Test suite for shell functions
- CI for validating config changes

------

## Files to Create/Modify

**New files:**

- `bootstrap/00-antidote.zsh`
- `bootstrap/01-plugins.zsh`
- `bootstrap/02-prompt.zsh`
- `bootstrap/03-compinit.zsh`
- `core/env.zsh`
- `core/options.zsh`
- `core/locale.zsh`
- `vendor/pnpm.zsh`
- `vendor/nvm.zsh`
- `vendor/homebrew.zsh`
- `node/package.json`
- `node/tsconfig.json`
- `node/src/detect-env.ts`
- `node/src/build-path.ts`
- `node/src/cache.ts`
- `TODO_NEW.md` (this plan as markdown)

**Modify:**

- `main.zsh` - Rewrite as thin orchestrator
- `.zshrc` - Minimize to 2-3 lines
- `lib/widgets.zsh` - Add caching, make conditional

**Delete (after migration):**

- `main-get-env.zsh` (moved to `core/env.zsh`)
- `main-zsh-config.zsh` (split into `core/`)
- `main-vendor.zsh` (moved to `vendor/`)
- Duplicate theme loading code
