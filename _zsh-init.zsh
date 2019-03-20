################################################
################### DEFAULTS ###################
################################################

# GET IP
IP=$(curl -s ipinfo.io/ip)
IP_A2='REDACTED-IP'
HOSTNAME=$(hostname);

if   [[ $IP = $IP_A2 ]]   then ZENV='a2'
else ZENV='local'
fi

# NODE VERSION 
NODE_CURRENT=$(node -v);
# if type "nvm" > /dev/null; then
#   NVM_CURRENT=$(nvm current);jm
# else echo "ERR";
# fi

# EDITOR_PREFERRED
if   [[ $ZENV = 'a2'      ]]  then EDITOR_PREFERRED=vi
elif [[ $ZENV = 'local'   ]]  then EDITOR_PREFERRED==/usr/bin/code
fi

# code() COMMAND, USING EDITOR_PREFERRED
if   [[ $ZENV = 'a2'       ]]  then code () { sudo "${HOME}/.npm-global/bin/jmate" "$@"; }
elif [[ $ZENV = 'local'    ]]  then code () { /usr/share/code/code "$@"; }
elif [[ -n $SSH_CONNECTION ]]  then code () { vi "$@"; }
else code () { vi "$@"; }
fi

# DIR COLORS
# eval `dircolors ${HOME}/.dircolors/dircolors-moonshine-master/dircolors.moonshine`;
eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# ALT DIR COLORS
# cp $(dirname $(gem which colorls))/yaml/files.yaml ~/.config/colorls/files.yaml`
