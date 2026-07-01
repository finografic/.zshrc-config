#!/bin/zsh
# ============================================================================ #
# NOTE: MAIN.ZSH - Orchestrator for zshrc-config
# ============================================================================ #

# This file is sourced AFTER bootstrap/ sequence which handles:
#   - Profiling (00-profiling.zsh)
#   - Antidote plugin manager (01-antidote.zsh)
#   - Plugin loading (02-plugins.zsh)
#   - Completion system (03-compinit.zsh)
#   - Prompt/p10k config (04-prompt.zsh)
# ============================================================================ #

# Increase function nesting limit (needed for complex prompts)
typeset -g -i FUNCNEST=1000

# ============================================================================ #
# NOTE: 1. ENVIRONMENT DETECTION
# ============================================================================ #

source "$ZSHRC_ROOT/core/env.zsh"

# Determine which environment we're running in
export ZENV=$(determine-environment)

# ============================================================================ #
# NOTE: 2. CODEX CHECK - EARLY EXIT for Codex agent shells
# ============================================================================ #

if [[ "${IS_CODEX:-}" = "true" || -n "${CODEX_CI:-}" || -n "${CODEX_THREAD_ID:-}" || "${__CFBundleIdentifier:-}" = "com.openai.codex" ]]; then
  source "$ZSHRC_ROOT/_zenvs/codex/codex.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 3. THEME CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/themes/default.theme.zsh"
source "$ZSHRC_ROOT/themes/themes.functions.zsh"
source "$ZSHRC_ROOT/themes/prompt.zsh"

# ============================================================================ #
# NOTE: 4. CORE ZSH CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/core/options.zsh"

# ============================================================================ #
# NOTE: 5. LOCALE SETTINGS
# ============================================================================ #

source "$ZSHRC_ROOT/core/locale.zsh"

# ============================================================================ #
# NOTE: 6. CORE INCLUDES for ALL ENVIRONMENTS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/fzf.zsh"

# ============================================================================ #
# NOTE: 7. CACHES CLEANUP
# ============================================================================ #

source "$ZSHRC_ROOT/lib/clean.zsh"

# ============================================================================ #
# NOTE: 8. VSCODE CHECK - EARLY EXIT for IDE terminals
# ============================================================================ #

if [[ "$TERM_PROGRAM" = "vscode" ]]; then
  source "$ZSHRC_ROOT/_zenvs/vscode/vscode.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 9. VENDOR TOOLS (pnpm, nvm)
# ============================================================================ #

# source "$ZSHRC_ROOT/lib/fzf.zsh"
source "$ZSHRC_ROOT/vendor/index.zsh"

# ============================================================================ #
# NOTE: 10. EDITOR CONFIGURATION
# ============================================================================ #

export EDITOR="nvim"
export VISUAL="nvim"
export IDE="code"
alias vim="${EDITOR} $@"

function edit() { $EDITOR "$@"; }

# VSCode aliases (macOS specific)
if [[ "$OS_NAME" = "macOS" ]]; then
  # alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
  alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
  PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export PATH="/opt/homebrew/bin/hs:$PATH"
fi

# ============================================================================ #
# NOTE: 11. FULL ENVIRONMENT SETUP (Terminal only, not VSCode/Docker)
# ============================================================================ #

# Loading indicator (200ms - gives "busy" impression during bootstrap)
# Uses compiled TypeScript: node/src/spinner.ts -> node/dist/spinner.mjs (tsdown/rolldown)
node "$ZSHRC_ROOT/packages/node/dist/spinner.mjs"

# Core libraries
# source "$ZSHRC_ROOT/lib/colors.zsh"

# PATH additions (consolidated; typeset -U PATH in bootstrap prevents duplicates)
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Common utilities
source "$ZSHRC_ROOT/lib/utils.zsh"
source "$ZSHRC_ROOT/lib/utils.disk.zsh"
# source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/dev.zsh"

# Terminal tools
source "$ZSHRC_ROOT/lib/ghostty.zsh"

# ============================================================================ #
# NOTE: 12. ENVIRONMENT-SPECIFIC CONFIGURATION
# ============================================================================ #

# macOS specific
if [[ "$OS_NAME" = "macOS" ]]; then
  source "$ZSHRC_ROOT/lib/macos.utils.zsh"
fi

# ============================================================================ #
# NOTE: 13. ZENV-SPECIFIC CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"

# ============================================================================ #
# NOTE: 14. CUSTOM SCRIPTS
# ============================================================================ #

# DJ software sync
source "$ZSHRC_ROOT/extras/music/djay_icloud_sync.zsh"

# Docker cleanup utilities
source "$ZSHRC_ROOT/scripts/docker-cleanup.zsh"

# GitHub authentication (silent)
[[ -n "$NPM_TOKEN" ]] && gh auth login --with-token < <(printf '%s' "$NPM_TOKEN") 2>/dev/null

# ============================================================================ #
# NOTE: 15. FINALIZATION
# ============================================================================ #

# Splash screen
source "$ZSHRC_ROOT/main-splash.zsh"

# Remove duplicate PATH entries (uses TypeScript: node/src/build-path.ts)
export PATH=$(node "$ZSHRC_ROOT/packages/node/dist/build-path.mjs")
