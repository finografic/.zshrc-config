################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# ENSURE SYYSTEM LANGUAGE IS en_US
export LANGUAGE=en_US.UTF-8



# export PATH="/Users/REDACTED/.nvm/versions/node/v12.20.2/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/REDACTED/bin:/usr/local/bin:/Users/REDACTED/.nvm/versions/node/v12.20.2/bin:/Users/REDACTED/.zshrc-config/bin/pfetch:/Users/REDACTED/.zshrc-config/bin/lsof:/Users/REDACTED/.eslintrc:/Users/REDACTED/.vimpkg/bin:/Users/REDACTED/.yarn/bin:/Users/REDACTED/.config/yarn/global/node_modules/.bin:/usr/bin/curl:/Users/REDACTED/.nvm/versions/node/v12.20.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/lib/node_modules:/Users/REDACTED/bin:/snap/bin:/Users/REDACTED/.eslintrc:/Users/REDACTED/.yarn/bin:/Users/REDACTED/.config/yarn/global/node_modules/.bin:/Users/REDACTED/bin/caddy:/Users/REDACTED/.fzf/bin:/Users/REDACTED/.vimpkg/bin:/usr/local/opt/fzf/bin:/Users/REDACTED/.vimpkg/bin"


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
  elif [ $OS_NAME = 'macOS' ]; then ports; # ports4;
  elif [ $OS_NAME = 'Android' ]; then # NADA
else ports; # DEFAULT ALIAS
fi;

# DISK SPACE
# DETERMINE ENVIRONMENT and POINT
# if [ $OS_NAME = 'Linux' ]; then diskspace_df_with_temps;
if [ $OS_NAME = 'Linux' ]; then diskspace_df_brief;
  elif [ $OS_NAME = 'macOS' ]; then diskspace_df_mac;
  elif [ $OS_NAME = 'Android' ]; then diskspace_df_mac 2> /dev/null;
else diskspace_df_brief; # DEFAULT ALIAS
fi;

# BANNER
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh";

D="${_c}::${_0}";
RESET_STRING="$HOSTNAME $D ${_w}$IP"

echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$OS_NAME \t $([[ $OS != "Android" ]] && echo "v$OS_VERSION") $([[ $OS = "Linux" ]] && echo $OS_KERNEL)"
[ -e /etc/os-release ] &&  echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
echo "${_c}NodeJS \t$(node --version)"
echo "${_c}npm \tv$(npm --version)\n${_0}"
