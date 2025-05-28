################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# CLEAN PATH
export PATH=$(echo "$PATH" | awk -v RS=':' '!a[$1]++{if(NR>1)printf":";printf $1}')

# TODO: MOVED TO main.zsh
# ENSURE SYYSTEM LANGUAGE IS en_US
# export LANGUAGE=en_US.UTF-8

echo "\n"

# ========================================================================= #
# LIST PORTS
[[ $OS_NAME = 'Linux' && $ZENV != "apnaes" ]] && ports
[ $OS_NAME = 'macOS' ] && ports
[ $OS_NAME = 'Android' ] && $(ports 2>/dev/null)
echo "\n"

# ========================================================================= #
# FASTFETCH, NERDFETCH, PFETCH, etc.

# NOTE: REMOVED IN FAVOR OF `fastfetch`
# echo "\n" && PF_COL3=3 PF_COL1=2 PF_COL2=2 PF_INFO="ascii os host kernel uptime pkgs memory" pfetch
# NOTE: REMOVED IN FAVOR OF NEW: clause below..
# $ZSHRC_ROOT/bin-$OS_ARCH/fastfetch

# ========================================================================= #
# NEW: FASTFETCH or NEOFETCH, based on SYSTEM ARCHITECTURE

# Check architecture and use appropriate binary
if [ $ZENV = "apnaes" ]; then
  # $ZSHRC_ROOT/bin-$OS_ARCH/neofetch
  # command -v neofetch >/dev/null && neofetch || echo "neofetch not found"
  command -v $ZSHRC_ROOT/bin-$OS_ARCH/neofetch >/dev/null && $ZSHRC_ROOT/bin-$OS_ARCH/neofetch || echo "neofetch not found"
else
  # Original x86_64 logic
  # $ZSHRC_ROOT/bin-$OS_ARCH/fastfetch
  # command -v fastfetch >/dev/null && fastfetch || echo "fastfetch not found"
  command -v $ZSHRC_ROOT/bin-$OS_ARCH/fastfetch >/dev/null && $ZSHRC_ROOT/bin-$OS_ARCH/fastfetch || echo "fastfetch not found"
fi

# ========================================================================= #
# DISK SPACE
# [[ $OS_NAME = 'Linux' && $ZENV != "apnaes" ]] && diskspace_df_brief # NOTE: REMOVED IN FAVOR OF `fastfetch`
# [ $OS_NAME = 'macOS' ] && diskspace_df_mac # NOTE: REMOVED IN FAVOR OF `fastfetch`
# [ $OS_NAME = 'Android' ] && $(diskspace_df_mac 2>/dev/null)

# ========================================================================= #
# BANNER
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh"

D="${_c}::${_0}"
RESET_STRING="$HOSTNAME $D ${_w}$IP"

echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$OS_NAME \t $([[ $OS != "Android" ]] && echo "$OS_VERSION") $([[ $OS = "Linux" ]] && echo $OS_KERNEL)"
[ -e /etc/os-release ] && echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
echo "${_c}NodeJS \t$(node --version)"
echo "${_c}npm \tv$(npm --version)\n${_0}"
