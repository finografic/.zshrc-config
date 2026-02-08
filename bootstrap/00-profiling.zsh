#!/bin/zsh
# ============================================================================ #
# NOTE: PROFILING - Enable zsh profiling (comment out when not needed)
# ============================================================================ #

# Load history first (was in original .zshrc before compinit)
source "$ZSHRC_ROOT/core/history.zsh"

# Uncomment to enable detailed profiling (run `zprof` at end of session)
# zmodload zsh/zprof

# Disable compfix warnings
ZSH_DISABLE_COMPFIX=true
