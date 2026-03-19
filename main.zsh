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
export ZENV=$(determine_environment)

# ============================================================================ #
# NOTE: 2. THEME CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/themes/default.theme.zsh"
source "$ZSHRC_ROOT/themes/themes.functions.zsh"
source "$ZSHRC_ROOT/themes/prompt.zsh"

# ============================================================================ #
# NOTE: 3. CORE ZSH CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/core/options.zsh"

# ============================================================================ #
# NOTE: 4. LOCALE SETTINGS
# ============================================================================ #

source "$ZSHRC_ROOT/core/locale.zsh"

# ============================================================================ #
# NOTE: 4. CORE INCLUDES for ALL ENVIRONMENTS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/fzf.zsh"

# ============================================================================ #
# NOTE: 5. DOCKER CONTAINER CHECK - Early exit for containers
# ============================================================================ #

if [[ -f /.dockerenv ]] || [[ -n "$DOCKER_CONTAINER" ]] || [[ -n "$IN_DOCKER" ]]; then
  export ZENV="docker-dev"
  export IN_DOCKER=1
  source "$ZSHRC_ROOT/_zenvs/docker-dev/docker-dev.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 6. VSCODE CHECK - Early exit for IDE terminals
# ============================================================================ #

if [[ "$TERM_PROGRAM" = "vscode" ]]; then
  source "$ZSHRC_ROOT/_zenvs/vscode/vscode.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 7. VENDOR TOOLS (pnpm, nvm)
# ============================================================================ #

# source "$ZSHRC_ROOT/lib/fzf.zsh"
source "$ZSHRC_ROOT/vendor/index.zsh"

# ============================================================================ #
# NOTE: 8. EDITOR CONFIGURATION
# ============================================================================ #

export EDITOR="nvim"
export VISUAL="nvim"
export IDE="code"
alias vim="${EDITOR} $@"

edit() { $EDITOR "$@"; }

# VSCode aliases (macOS specific)
if [[ "$OS_NAME" = "macOS" ]]; then
  alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
    alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
  export PATH="/opt/homebrew/bin/hs:$PATH"
fi

# ============================================================================ #
# NOTE: 9. FULL ENVIRONMENT SETUP (Terminal only, not VSCode/Docker)
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
source "$ZSHRC_ROOT/lib/clean.node.zsh" # functions

# Terminal tools
source "$ZSHRC_ROOT/lib/ghostty.zsh"

# ============================================================================ #
# NOTE: 10. ENVIRONMENT-SPECIFIC CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"

# ============================================================================ #
# NOTE: 11. CUSTOM SCRIPTS
# ============================================================================ #

# DJ software sync
source "$ZSHRC_ROOT/extras/music/djay_icloud_sync.zsh"

# Docker cleanup utilities
source "$ZSHRC_ROOT/scripts/docker-cleanup.zsh"

# GitHub authentication (silent)
[[ -n "$NPM_TOKEN" ]] && gh auth login --with-token < <(printf '%s' "$NPM_TOKEN") 2>/dev/null

# ============================================================================ #
# NOTE: 12. FINALIZATION
# ============================================================================ #

# Splash screen
source "$ZSHRC_ROOT/main-splash.zsh"

# Remove duplicate PATH entries (uses TypeScript: node/src/build-path.ts)
export PATH=$(node "$ZSHRC_ROOT/packages/node/dist/build-path.mjs")
