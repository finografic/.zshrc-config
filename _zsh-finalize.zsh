################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

export LC_ALL=C
# nvm use v8.11.3 
# rvm use ruby-2.5.1 # NECESSARY TO SET RUBY PATH

# NODE VERSION
if hash rvm 2>/dev/null; then
   source $HOME/.rvm/scripts/rvm
fi

[ -f $HOME/.fzf.zsh ] && source ${HOME}/.fzf.zsh
# ONLY FOR FIRST-TIME (??)
# # source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# GIT SYNC ZSHRC AUTOMATICALLY - DANGER ??
# FOLLOWING REQUIRES 'sudo'
# cd $ZSH_CONFIG
# git fetch
# $HOME/.zshrc-config/node_modules/git-auto/bin/git-auto -p

# INIT DIR
cd $HOME

ports;
pm2 ls;
echo "\n"
pydf --human-readable;

# BANNER
source "$ZSH_CONFIG/_${ZENV}/${ZENV}-banner.zsh";

D="\e[36m::\033[0m";
RESET_STRING="$HOSTNAME $D $IP $D zsh reset"
echo "\n\e[36m ---=====\e[37m $RESET_STRING \e[36m=====--- \n"
