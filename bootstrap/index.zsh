#!/bin/zsh
# ============================================================================ #
# NOTE: BOOTSTRAP INDEX - Loads all bootstrap files in correct order
# ============================================================================ #

# This file is sourced by ~/.zshrc after setting ZSHRC_ROOT
# Order matters! Do not rearrange without understanding dependencies.
# ============================================================================ #

# Shared environment predicates (is-agent-shell, is-container, ...). Must come
# first: the Codex early-exit below depends on it.
source "$ZSHRC_ROOT/core/detect.zsh"

# Codex agent shells get nothing from bootstrap — main.zsh loads the minimal
# codex profile and returns.
if is-agent-shell; then
  return 0
fi

# Keep $PATH de-duplicated for the whole session. zsh ties `path` to `PATH`, so
# this one line does natively what build-path.mjs used to spawn node for.
typeset -U path PATH

# Load colors module (used throughout the config)
source "$ZSHRC_ROOT/lib/colors.zsh"

# 1. Profiling and settings (must be first)
source "$ZSHRC_ROOT/bootstrap/00-profiling.zsh"

# 2. Completion system MUST be before plugins (plugins use compdef)
source "$ZSHRC_ROOT/bootstrap/03-compinit.zsh"

# 3-4. Antidote + plugins (skipped in containers — docker-dev.zsh handles its own setup)
if ! is-container; then
  source "$ZSHRC_ROOT/bootstrap/01-antidote.zsh"
  source "$ZSHRC_ROOT/bootstrap/02-plugins.zsh"
fi

# 5. Prompt configuration (p10k settings + user config)
source "$ZSHRC_ROOT/bootstrap/04-prompt.zsh"
