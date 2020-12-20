################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# ENSURE SYYSTEM LANGUAGE IS en_US
export LANGUAGE=en_US.UTF-8

# CLEAN DUPLICATES IN PATH (AGAIN)
flatten_PATH;

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

# NEW PM2 COMMAND
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "env PATH=\$PATH:${NPM_GLOBALS}/pm2 startup systemd -u ${USER} --hp ${HOME}";
[ -e ${NPM_GLOBALS}/pm2 ] && eval "${NPM_GLOBALS}/pm2 list --sort id:asc";

# PFETCH
echo "\n" && PF_COL3=3 PF_COL1=2 PF_COL2=2 PF_INFO="ascii os host kernel uptime pkgs memory" pfetch;

# LIST PORTS
# ports;
if [ "$ZENV" != "android" ]; then ports; fi;

# DISK SPACE
space;

# BANNER
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh";

D="${_c}::${_0}";
RESET_STRING="$HOSTNAME $D ${_w}$IP"
echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"

# VERSIONS: OS, NodeJS, npm... etc
echo "${_y}$(uname -o) - $(uname -s) $(uname -r)"
[ -e /etc/os-release ] &&  echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
echo "${_c}NodeJS $(node --version)"
echo "${_c}npm v$(npm --version)\n${_0}"






