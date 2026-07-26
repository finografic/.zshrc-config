# ============================================================================ #
# NOTE: MAIN.ZSH - Orchestrator for zshrc-config (sourced, not executed)
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

# Determine which environment we're running in. This is the ONLY place $ZENV is
# resolved — everything downstream reads it. Sets ZENV + ZENV_RESOLVED_BY.
determine-environment
export ZENV
apply-environment-env

# Every profile resolves its own path; set it once here so the manifest loader
# and the profiles agree on it.
export ZENV_PATH="$ZSHRC_ROOT/profiles/$ZENV"

# Profile manifest loader (definitions only — profiles call `zenv-load`).
source "$ZSHRC_ROOT/core/profile.zsh"

# ============================================================================ #
# NOTE: 2. CORE INCLUDES for ALL ENVIRONMENTS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/fzf.zsh"

# ============================================================================ #
# NOTE: 3. CODEX CHECK - EARLY EXIT for Codex agent shells
# ============================================================================ #

if is-agent-shell; then
  source "$ZSHRC_ROOT/profiles/codex/codex.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 4. THEME CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/themes/default.theme.zsh"
source "$ZSHRC_ROOT/themes/themes.functions.zsh"
source "$ZSHRC_ROOT/themes/prompt.zsh"

# ============================================================================ #
# NOTE: 5. CORE ZSH CONFIGURATION
# ============================================================================ #

source "$ZSHRC_ROOT/core/options.zsh"

# ============================================================================ #
# NOTE: 6. LOCALE SETTINGS
# ============================================================================ #

source "$ZSHRC_ROOT/core/locale.zsh"

# ============================================================================ #
# NOTE: 8. VSCODE CHECK - EARLY EXIT for IDE terminals
# ============================================================================ #

if is-ide-shell; then
  source "$ZSHRC_ROOT/profiles/vscode/vscode.zsh"
  return 0
fi

# ============================================================================ #
# NOTE: 9. EDITOR CONFIGURATION
# ============================================================================ #

export EDITOR="nvim"
export VISUAL="nvim"
export IDE="code"

# NOTE: `$@` in an alias expands at DEFINITION time (to nothing), not at call
# time — the argument passing this looked like it did never worked.
alias vim="$EDITOR"

function edit() { $EDITOR "$@"; }

# VSCode alias (macOS specific). PATH belongs to lib/paths/paths.macos.zsh —
# see the PATH-ownership rule in docs/ARCHITECTURE.md.
if [[ "$OS_NAME" = "macOS" ]]; then
  alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
fi

# ============================================================================ #
# NOTE: 10. ZENV-SPECIFIC CONFIGURATION
#
# The profile declares what it wants (ZENV_PRESET / ZENV_MODULES /
# ZENV_FEATURES) and calls `zenv-load`. Everything main.zsh used to source
# unconditionally here — vendor tools, lib/ barrels, the macOS modules — is now
# resolved from that manifest, in the canonical order core/profile.zsh defines.
# ============================================================================ #

source "$ZSHRC_ROOT/profiles/$ZENV/$ZENV.zsh"

# ============================================================================ #
# NOTE: 11. FINALIZATION
#
# extras/ is opt-in and is never sourced from here — see the layer table in
# docs/ARCHITECTURE.md. A profile declares them via ZENV_OPT_IN.
# ============================================================================ #

# Splash screen
source "$ZSHRC_ROOT/main-splash.zsh"
