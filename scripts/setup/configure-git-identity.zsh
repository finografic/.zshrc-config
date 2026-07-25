#!/bin/zsh

# Interactive one-time setup of your global git identity.
# Run manually per machine: scripts/setup/configure-git-identity.zsh
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function configure-git-identity() {
  local current_name current_email name email

  current_name=$(git config --global user.name 2>/dev/null)
  current_email=$(git config --global user.email 2>/dev/null)

  print "${_c}Configure global git identity${_0}"
  [[ -n "$current_name" ]] && print "  current user.name:  ${_y}${current_name}${_0}"
  [[ -n "$current_email" ]] && print "  current user.email: ${_y}${current_email}${_0}"

  print -n "git user.name: "
  read name
  print -n "git user.email: "
  read email

  if [[ -z "$name" || -z "$email" ]]; then
    print "${_r}Aborted — name and email are required.${_0}"
    return 1
  fi

  git config --global user.name "$name"
  git config --global user.email "$email"
  git config --global color.ui true

  print -n "Cache git credentials for 2 weeks? (y/N) "
  read confirm
  if [[ "$confirm" == [yY] ]]; then
    git config --global credential.helper 'cache --timeout=1209600'
  fi

  print "${_g}Done.${_0} user.name=${name} user.email=${email}"
}

configure-git-identity
