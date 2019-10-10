################################################
###################  COLORS  ###################
################################################

# exa file listing
export env EXA_COLORS="da=1;34" # brighter blues

# COLOR RESOURCE:
# https://misc.flogisoft.com/bash/tip_colors_and_formatting


# MY COLORS !! :)
_B="\e[1m";           # BOLD
_r="$_B\e[31m"        # Red
_g="$_B\e[32m"        # Green
_y="$_B\e[33m"        # Yellow
_b="$_B\e[34m"        # Blue
_p="$_B\e[35m"        # Purple
_c="$_B\e[36m"        # Cyan
_w="$_B\e[37m"        # White
_0="\e[0m"            # Reset


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