################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# TODO: MOVED TO main.zsh
# ENSURE SYYSTEM LANGUAGE IS en_US
# export LANGUAGE=en_US.UTF-8

# ============ #
# PFETCH
echo "\n" && PF_COL3=3 PF_COL1=2 PF_COL2=2 PF_INFO="ascii os host kernel uptime pkgs memory" pfetch;

# LIST PORTS
[[ $OS_NAME = 'Linux'] && [$ZENV != "apnaes" ]] && ports
[ $OS_NAME = 'macOS' ] && ports
[ $OS_NAME = 'Android' ] && ports 2> /dev/null

# DISK SPACE
[[ $OS_NAME = 'Linux'] && [$ZENV != "apnaes" ]] && diskspace_df_brief
[ $OS_NAME = 'macOS' ] && diskspace_df_mac
[ $OS_NAME = 'Android' ] && diskspace_df_mac 2> /dev/null

# BANNER
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh";

D="${_c}::${_0}";
RESET_STRING="$HOSTNAME $D ${_w}$IP"

echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$OS_NAME \t $([[ $OS != "Android" ]] && echo "$OS_VERSION") $([[ $OS = "Linux" ]] && echo $OS_KERNEL)"
[ -e /etc/os-release ] &&  echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
echo "${_c}NodeJS \t$(node --version)"
echo "${_c}npm \tv$(npm --version)\n${_0}"
