#!/bin/zsh
# ============================================================================ #
# NOTE: PROFILING - Enable zsh profiling (comment out when not needed)
# ============================================================================ #

# Load history first (was in original .zshrc before compinit)
source "$ZSHRC_ROOT/core/history.zsh"

# PATH de-duplication is handled once, earlier, by `typeset -U path PATH` in
# bootstrap/index.zsh — this used to be a second, redundant `typeset -U PATH`.

# Set ZSHRC_PROFILE=1 to get a per-function zprof breakdown for this shell:
#   ZSHRC_PROFILE=1 zsh -i -c exit
# The report prints automatically on exit via a zshexit hook.
if [[ "${ZSHRC_PROFILE:-0}" == 1 ]]; then
  zmodload zsh/zprof
  function _zshrc_profile_report() { zprof }
  autoload -Uz add-zsh-hook
  add-zsh-hook zshexit _zshrc_profile_report
fi

# Disable compfix warnings
ZSH_DISABLE_COMPFIX=true
