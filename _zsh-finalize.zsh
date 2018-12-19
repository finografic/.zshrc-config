################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

export LC_ALL=C
# nvm use v8.11.3 
# rvm use ruby-2.5.1 # NECESSARY TO SET RUBY PATH
source ~/.rvm/scripts/rvm
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ONLY FOR FIRST-TIME (??)
# # source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

echo "\n\e[35m";

if [[ $IP = $IP_GD ]] then

cat << EOF
e   e  eeeee e  
8   8  8   8 8  
8eee8e 8eee8 8e 
88   8 88    88 
88   8 88    88 
EOF

elif [[ $IP = $IP_AWS ]] then

cat << EOF
eeeee e   e  e eeeee 
8   8 8   8  8 8   " 
8eee8 8e  8  8 8eeee 
88  8 88  8  8    88 
88  8 88ee8ee8 8ee88 
EOF

else

cat << EOF
e     eeeee eeee eeeee e     
8     8  88 8  8 8   8 8     
8e    8   8 8e   8eee8 8e    
88    8   8 88   88  8 88    
88eee 8eee8 88e8 88  8 88eee 
EOF

fi

echo "\n"
HOSTNAME=$(hostname);
hostname;
ports;
pm2 ls;
echo "\n"
pydf;

D="\e[36m::\033[0m";
RESET_STRING="$HOSTNAME $D $IP $D ZSH reset"
echo "\n\n\e[36m ---=====\e[37m $RESET_STRING \e[36m=====--- \n\n"
