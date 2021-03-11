################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# ENSURE SYYSTEM LANGUAGE IS en_US
export LANGUAGE=en_US.UTF-8

# CLEAN DUPLICATES IN PATH (AGAIN?)
# flatten_PATH;

# FORM rvm // RVM VERSION
# [ -e /etc/profile.d/rvm.sh ] && source /etc/profile.d/rvm.sh
# [ -e ${HOME}/.rvm/scripts/rvm ] && source ${HOME}/.rvm/scripts/rvm

# INIT FZF
[ -e ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

# ONLY FOR FIRST-TIME (??)
# # source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# GIT SYNC ZSHRC AUTOMATICALLY - DANGER ??
# FOLLOWING REQUIRES 'sudo'
# cd $ZSHRC_ROOT
# git fetch
# $HOME/.zshrc-config/node_modules/git-auto/bin/git-auto -p

# PM2 CHECK + DISPLAY
[ -e ${NPM_GLOBALS}/pm2 ] && eval "${NPM_GLOBALS}/pm2 list";

# PFETCH
echo "\n" && PF_COL3=3 PF_COL1=2 PF_COL2=2 PF_INFO="ascii os host kernel uptime pkgs memory" pfetch;

# LIST PORTS
# ports;
# if [ "$ZENV" != "android" ]; then ports; fi;
# DETERMINE ENVIRONMENT and POINT
if [ $OS_NAME = 'Linux' ]; then ports;
elif [ $OS_NAME = 'MacOS' ]; then ports; # ports4;
elif [ $OS_NAME = 'Android' ]; then # NADA
else ports; # DEFAULT ALIAS
fi;

# DISK SPACE
# DETERMINE ENVIRONMENT and POINT
if [ $OS_NAME = 'Linux' ]; then diskspace_df_with_temps;
elif [ $OS_NAME = 'MacOS' ]; then diskspace_df_mac;
elif [ $OS_NAME = 'Android' ]; then diskspace_df_with_temps;
else space; # DEFAULT ALIAS
fi;

# BANNER
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh";

D="${_c}::${_0}";
RESET_STRING="$HOSTNAME $D ${_w}$IP"

echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$OS_NAME \tv$OS_VERSION $([[ $OS = "Linux" ]] && echo $OS_KERNEL)"
[ -e /etc/os-release ] &&  echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
echo "${_c}NodeJS \t$(node --version)"
echo "${_c}npm \tv$(npm --version)\n${_0}"






