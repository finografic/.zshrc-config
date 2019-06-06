################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

export LC_ALL=C
nvm use v12.2.0 
# rvm use ruby-2.5.1 # NECESSARY TO SET RUBY PATH

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
sudo env PATH=$PATH:/home/REDACTED/.nvm/versions/node/v12.2.0/bin /home/REDACTED/.nvm/versions/node/v12.2.0/lib/node_modules/pm2/bin/pm2 startup systemd -u justin --hp /home/REDACTED

# LIST PORTS
ports;
echo "\n"

# SHOW DISK USAGE
pydf --human-readable;

# BANNER
source "$ZSH_CONFIG/_${ZENV}/${ZENV}-banner.zsh";

D="\e[36m::\033[0m";
RESET_STRING="$HOSTNAME $D $IP $D zsh reset"
echo "\n\e[36m ---=====\e[37m $RESET_STRING \e[36m=====--- \n"
