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
git fetch
cd $HOME/.zshrc-config/node_modules/git-auto/bin/git-auto -p

ports;
pm2 ls;
echo "\n"
pydf --human-readable;

echo "\e[35m";

# ASCII GENERATOR: https://www.askapache.com/online-tools/figlet-ascii/

if [[ $IP = $IP_GD ]] then

cat << EOF
   __ _____  ____
  / //_/ _ \/  _/
 / ,< / ___// /  
/_/|_/_/  /___/              
EOF

elif [[ $IP = $IP_AWS ]] then

cat << EOF
   ___ _      ______
  / _ | | /| / / __/
 / __ | |/ |/ /\ \  
/_/ |_|__/|__/___/   
EOF

else

cat << EOF
   __   ____  ________   __ 
  / /  / __ \/ ___/ _ | / / 
 / /__/ /_/ / /__/ __ |/ /__
/____/\____/\___/_/ |_/____/
EOF

fi

D="\e[36m::\033[0m";
RESET_STRING="$HOSTNAME $D $IP $D ZSH reset"
echo "\n\e[36m ---=====\e[37m $RESET_STRING \e[36m=====--- \n"
