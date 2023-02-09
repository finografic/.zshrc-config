#!/bin/zsh

# SET NODE VERSION
export NVM_DIR="$HOME/.nvm"
[ OS_NAME="Android" ] && unset PREFIX;
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm

# NVM home-mac ONLY - TODO: FIX WITH ABOVE!
if [ $ZENV = 'home-macos'  ]; then
  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh";
  [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm";
fi;

# DETERMINE ENVIRONMENT and POINT
NODE_VERSION_PREFERRED=16; # DEFAULT ALIAS
[ $OS_NAME = 'Linux'      ] && NODE_VERSION_PREFERRED=16;
[ $OS_NAME = 'macOS'      ] && NODE_VERSION_PREFERRED=16;
[ $OS_NAME = 'Android'    ] && NODE_VERSION_PREFERRED=14;
[ $ZENV    = 'office-macos' ] && NODE_VERSION_PREFERRED=18;
nvm use $NODE_VERSION_PREFERRED;

export NODE_CURRENT_VERSION=$(node --version)
# export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/lib/node_modules/
export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin
