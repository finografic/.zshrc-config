# ============================================================================ #
# COLORS
# ============================================================================ #

# Guard: sourcing this file twice must be free. Lets every module that uses
# ${_c}-style vars open with `source "$ZSHRC_ROOT/lib/colors.zsh"` — the first
# call does the work, every later one returns after one arithmetic test.
(( ${+_ZSHRC_COLORS_LOADED} )) && return 0
typeset -g _ZSHRC_COLORS_LOADED=1

# eza file listing
# NOTE: this used to be `export env EXA_COLORS=...` — `export` takes multiple
# space-separated NAME[=VALUE] arguments, so that line silently exported a
# second variable literally named `env` (empty) alongside EXA_COLORS.
export EXA_COLORS="da=1;34" # brighter blues

# COLOR RESOURCE:
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

# COLOR UTILS
#
# NOTE: these are `typeset -g`, not `export`. 23 exported color vars leaked
# into the environment of every child process this shell spawns (visible in
# `env`, subprocess memory, anything that dumps env in logs) for no reason —
# they are only ever used in-shell via ${_c} expansion. Nothing depends on
# them being exported: every script that uses them (extras/music/*.zsh,
# scripts/docker-cleanup.zsh — both run as separate processes via launchd/cron)
# already sources this file itself rather than relying on inheritance.
typeset -g _d="\033[2m" # DIMMED
typeset -g _0="\033[0m" # Reset

# Generic bold. NOTE: named _bold, not _B — see the uppercase block below for
# why _B specifically was not available.
typeset -g _bold="\033[1m"

# REGULAR
typeset -g _grey="$_d\033[37m" # Grey (dim white)
typeset -g _gray="$_d\033[37m" # Grey (dim white)
typeset -g _r="\033[31m"       # Red
typeset -g _g="\033[32m"       # Green
typeset -g _y="\033[33m"       # Yellow
typeset -g _b="\033[34m"       # Blue
typeset -g _p="\033[35m"       # Purple
typeset -g _m="\033[35m"       # Magenta
typeset -g _c="\033[36m"       # Cyan
typeset -g _w="\033[37m"       # White

# BOLD / BRIGHT — the bold variant of each color, named as its uppercase letter.
#
# NOTE: this used to double-book _B. The file first defined _B as generic bold
# (\033[1m), then a few lines later reassigned _B to "$_B\033[34m" (bold+blue)
# to fit this block's own naming convention — silently clobbering the earlier
# value. Any caller wanting plain bold via ${_B} got bold-BLUE instead, which
# actually changed rendered output: lib/git/git.maintenance.zsh combines
# ${_y}${_B} expecting yellow-bold, but since ANSI foreground codes don't
# compose (the last one wins), that sequence rendered as blue, not yellow.
# Fixed by giving generic bold its own name (_bold, above) and updating that
# caller. This block keeps the uppercase-letter convention intact.
typeset -g _GREY="$_bold$_d\033[37m" # Grey (dim white)
typeset -g _GRAY="$_bold$_d\033[37m" # Grey (dim white)
typeset -g _R="$_bold\033[31m"       # Red
typeset -g _G="$_bold\033[32m"       # Green
typeset -g _Y="$_bold\033[33m"       # Yellow
typeset -g _B="$_bold\033[34m"       # Blue
typeset -g _P="$_bold\033[35m"       # Purple
typeset -g _M="$_bold\033[35m"       # Magenta
typeset -g _C="$_bold\033[36m"       # Cyan
typeset -g _W="$_bold\033[37m"       # White

# Force-strip the export attribute from every var above.
#
# `typeset -g` on a name that is ALREADY exported does not remove the export
# flag — it only updates the value. Every one of these vars WAS exported by
# this file until now, so any ancestor shell in your chain that is still
# running old config (a tmux server, a login shell predating this update) has
# already exported them into the environment this shell inherits. Without
# this, `typeset -g` above would silently keep leaking them into child
# processes on exactly the machines this change is meant to help — a fresh
# `zsh -f` cannot reproduce the bug, since it starts with a clean environment,
# but a real long-lived session can and does.
typeset +x _d _0 _bold _grey _gray _r _g _y _b _p _m _c _w \
  _GREY _GRAY _R _G _Y _B _P _M _C _W

# FROM ZGEN:
function setup-color() {
  # Only use colors if connected to a terminal
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

# 0: RESET
# 1: Bold/Bright
# 2: Dim
# 4: Underlined
# 5: Blink
