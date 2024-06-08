#!/bin/zsh

# NEW!! - attempt to fix VSCode better resolving shell environment
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096";

# DETERMINE OS + IP ========================================================== #

# WHICH SYS/OS ARE WE ON ??
if [ "$(sw_vers -productName 2> /dev/null)" ]; then
  productName="$(sw_vers -productName)";
  [ $productName = "Mac OS X" ] || [ $productName = "macOS" ] && export OS_NAME="macOS" || export OS_NAME=$(sw_vers -productName);
  export OS_VERSION=$(sw_vers -productVersion);
  export OS_KERNEL=$(sw_vers -buildVersion); # NOT ACTUALLY "KERNEL" ON macOS HERE
else
  [[ $(uname -o) = "GNU/Linux" ]] && export OS_NAME="Linux" || export OS_NAME=$(uname -o);
  export OS_VERSION=$(uname -s);
  export OS_KERNEL=$(uname -r);
fi;

OS_NAME_LOWER=$(echo $OS_NAME | awk '{print tolower($0)}');

# HOSTNAME
export HOSTNAME=$(hostname);

# GET IP ADDRESS
# [[ $(ipconfig 2> /dev/null) ]] && export IP=$(ipconfig getifaddr en0) || export IP=$(curl -s ipinfo.io/ip);
[ $(ipconfig getifaddr en0 2> /dev/null) ] && export IP=$(ipconfig getifaddr en0) || export IP=$(curl -s ipinfo.io/ip);
IP_APNAES='REDACTED-IP';
IP_OFFICE_MAC='REDACTED-IP';
IP_HOME='REDACTED-IP'; # OLD HOME IP ??
IP_HOME_MAC='REDACTED-IP';

export PATH_ZSHRC=$HOME; # DEFAULT - $(pwd) COULD BE USED ??

# DETERMINE ENVIRONMENT ====================================================== #

if [ $IS_HOME = true ]; then

    # DEFAULT FROM .env: HOME (MACOS)
    export ZENV='home-macos'
    export ZSH_THEME="gallois"

  elif [ $IS_OFFICE = true ]; then

    # OFFICE: (MACOS)
    export ZENV='office-macos'
    export ZSH_THEME="gallois"

  elif [ $IS_SERVER = true ]; then
    # SERVER: APNAES
    export OS_NAME='Linux'
    export ZENV='apnaes'
    export ZSH_THEME="gallois"
  elif [ $IP = $IP_APNAES ]; then
    # SERVER: APNAES
    export OS_NAME='Linux'
    export ZENV='apnaes'
    export ZSH_THEME="gallois"

  elif [ $OS_NAME = 'Android' ]; then

    # MOBILE: (ANDROID + TMUX)
    export ZENV='android'
    export ZSH_THEME="gallois"
    export STORAGE_ROOT="${HOME}"
    export PATH_ZSHRC=$STORAGE_ROOT

  elif [ $OS_NAME = 'Android' ]; then

    # HOME: (LINUX)
    export OS_NAME='Linux'
    export ZENV='home'
    export ZSH_THEME="fino-time"

else

    # DEFAULT: HOME (MACOS)
    export ZENV='home-macos'
    export ZSH_THEME="gallois"

fi;
