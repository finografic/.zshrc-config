################################################
################### DEFAULTS ###################
################################################

# GET IP
IP=$(curl -s ipinfo.io/ip)
IP_GD='REDACTED-IP' 
IP_AWS='REDACTED-IP'
HOSTNAME=$(hostname);

if [[ $IP = $IP_GD ]] then ZENV='godaddy'
elif [[ $IP = $IP_AWS ]] then ZENV='aws'
else ZENV='local'
fi

# NODE VERSION
NVM_CURRENT=$(nvm current);
# if hash nvm 2>/dev/null; then
#   NODE_CURRENT=$(nvm current)
# fi

# EDITOR_PREFERRED=nano
EDITOR_PREFERRED=vi
# EDITOR_PREFERRED=/usr/bin/code

if [[ -n $SSH_CONNECTION ]]; then
  # IS REMOTE
  IS_SSH=true
  export EDITOR="vi"
  if [[ $IP = $IP_GD ]] then
    code () { sudo "${HOME}/.npm-global/bin/jmate" "$@"; }
  elif [[ $IP = $IP_AWS ]] then
    code () { sudo "${HOME}/.nvm/versions/node/${NVM_CURRENT}/bin/jmate" "$@"; }
  else
    code () { /usr/share/code/code "$@"; }
  fi
fi

# cp $(dirname $(gem which colorls))/yaml/files.yaml ~/.config/colorls/files.yaml`

# DIR COLORS
# eval `dircolors ${HOME}/.dircolors/dircolors-moonshine-master/dircolors.moonshine`;
eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;