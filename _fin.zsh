################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# CLEAN DUPLICATES IN PATH (AGAIN)
export PATH=$(printf %s "$PATH" | awk -vRS=: '!a[$0]++' | paste -s -d:);

export LC_ALL=C

# FORM rvm // RVM VERSION
# [ -e /etc/profile.d/rvm.sh ] && source /etc/profile.d/rvm.sh
# [ -e ${HOME}/.rvm/scripts/rvm ] && source ${HOME}/.rvm/scripts/rvm

# INIT FZF
[ -e ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

# ONLY FOR FIRST-TIME (??)
# # source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# GIT SYNC ZSHRC AUTOMATICALLY - DANGER ??
# FOLLOWING REQUIRES 'sudo'
# cd $ZSH_CONFIG
# git fetch
# $HOME/.zshrc-config/node_modules/git-auto/bin/git-auto -p

# INIT DIR
cd $HOME

# NEW PM2 COMMAND
# pm2 list --sort id:asc;
env PATH=$PATH:/home/REDACTED/.nvm/versions/node/v12.2.0/bin /home/REDACTED/.nvm/versions/node/v12.2.0/lib/node_modules/pm2/bin/pm2 startup systemd -u justin --hp /home/REDACTED

# DISK SPACE
# space;

# LIST PORTS
# ports;
if [ "$ZENV" != "android" ]; then ports; fi;


# grc netstat -plnt | grep ":::" -v

# BANNER
source "$ZSH_CONFIG/_zenvs/${ZENV}/${ZENV}-banner.zsh";

D="${_c}::${_0}";
RESET_STRING="$HOSTNAME $D ${_w}$IP"
echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$(uname -o) - $(uname -s) $(uname -r)"
echo "${_0}\e[36mUsing ${_c}NodeJS $(node --version)"
echo "${_0}\e[36mUsing ${_c}npm v$(npm --version)\n"




