################################################
################### DEFAULTS ###################
################################################

# GET IP
IP=$(curl -s ipinfo.io/ip)
IP_GD='REDACTED-IP' 
IP_AWS='REDACTED-IP'
# IP_AWS='REDACTED-IP' # OLD

# NODE VERSION
NODE_CURRENT=$(nvm current)
# EDITOR_PREFERRED=nano
EDITOR_PREFERRED=vi
# EDITOR_PREFERRED=/usr/bin/code

if [[ -n $SSH_CONNECTION ]]; then
  # IS REMOTE
  IS_SSH=true
  export EDITOR="vim"
  if [[ $IP = $IP_GD ]] then
    code () { sudo "${HOME}/.npm-global/bin/jmate" "$@"; }
  elif [[ $IP = $IP_AWS ]] then
    code () { sudo "${HOME}/.nvm/versions/node/${NODE_CURRENT}/bin/jmate" "$@"; }
  else
    code () { /usr/share/code/code "$@"; }
  fi
# cp $(dirname $(gem which colorls))/yaml/files.yaml ~/.config/colorls/files.yaml`

# DIR COLORS
eval `dircolors ${HOME}/.dircolors/dircolors-moonshine-master/dircolors.moonshine`
# eval "$(dircolors /etc/DIR_COLORS)"
# dircolors --print-database
# eval "$(dircolors)"
