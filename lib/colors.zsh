################################################
###################  COLORS  ###################
################################################

# exa file listing
export env EXA_COLORS="da=1;34" # brighter blues

# COLOR RESOURCE:
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

# MY COLORS !! :)
# COLOR UTILS
export _B="\033[1m" # BOLD
export _d="\033[2m" # DIMMED
export _0="\033[0m" # Reset

# REGULAR
export _grey="$_d\033[37m" # Grey (dim white)
export _gray="$_d\033[37m" # Grey (dim white)
export _r="\033[31m"       # Red
export _g="\033[32m"       # Green
export _y="\033[33m"       # Yellow
export _b="\033[34m"       # Blue
export _p="\033[35m"       # Purple
export _m="\033[35m"       # Magenta
export _c="\033[36m"       # Cyan
export _w="\033[37m"       # White

# BOLD / BRIGHT
export _GREY="$_B$_d\033[37m" # Grey (dim white)
export _GRAY="$_B$_d\033[37m" # Grey (dim white)
export _R="$_B\033[31m"       # Red
export _G="$_B\033[32m"       # Green
export _Y="$_B\033[33m"       # Yellow
export _B="$_B\033[34m"       # Blue
export _P="$_B\033[35m"       # Purple
export _M="$_B\033[35m"       # Magenta
export _C="$_B\033[36m"       # Cyan
export _W="$_B\033[37m"       # White

# BETTER RESET ???
# \x1b[0m

# FROM ZGEN:
setup_color() {
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
