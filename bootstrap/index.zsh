#!/bin/zsh
# ============================================================================ #
# NOTE: BOOTSTRAP INDEX - Loads all bootstrap files in correct order
# ============================================================================ #
# This file is sourced by ~/.zshrc after setting ZSHRC_ROOT
# Order matters! Do not rearrange without understanding dependencies.
# ============================================================================ #

# Load colors module (used throughout the config)
source "$ZSHRC_ROOT/lib/colors.zsh"

# 1. Profiling and settings (must be first)
source "$ZSHRC_ROOT/bootstrap/00-profiling.zsh"

# 2. Completion system MUST be before plugins (plugins use compdef)
source "$ZSHRC_ROOT/bootstrap/03-compinit.zsh"

# 3-4. Antidote + plugins (skipped in docker — docker-dev.zsh handles its own setup)
if [[ ! -f /.dockerenv ]] && [[ -z "$IN_DOCKER" ]] && [[ -z "$DOCKER_CONTAINER" ]]; then
  source "$ZSHRC_ROOT/bootstrap/01-antidote.zsh"
  source "$ZSHRC_ROOT/bootstrap/02-plugins.zsh"
fi

# 5. Prompt configuration (p10k settings + user config)
source "$ZSHRC_ROOT/bootstrap/04-prompt.zsh"
