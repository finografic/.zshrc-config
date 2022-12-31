################################################
###################  COLORS  ###################
################################################

# exa file listing
export env EXA_COLORS="da=1;34" # brighter blues

# COLOR RESOURCE:
# https://misc.flogisoft.com/bash/tip_colors_and_formatting


# MY COLORS ================================== #

# UTILITY EFFECTS
export _B="\e[1m";           # BOLD
export _D="\e[2m";           # DIMMED

export _black="$_D\e[30m"    # Grey (dim white)
export _white="$_B\e[37m"    # White
export _grey="$_D\e[37m"     # Grey (dim white)
export _gray="$_D\e[37m"     # Grey (bold black)


# BOLD (DEFALUT)
export _r="$_B\e[31m"        # Red
export _g="$_B\e[32m"        # Green
export _y="$_B\e[33m"        # Yellow
export _b="$_B\e[34m"        # Blue
export _p="$_B\e[35m"        # Purple
export _c="$_B\e[36m"        # Cyan


# DIMMED
export __r="$_D\e[31m"        # Red
export __g="$_D\e[32m"        # Green
export __y="$_D\e[33m"        # Yellow
export __b="$_D\e[34m"        # Blue
export __p="$_D\e[35m"        # Purple
export __c="$_D\e[36m"        # Cyan

# RESET
export _0="\e[0m"            # Reset
# \x1b[0m # BETTER RESET ???


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
