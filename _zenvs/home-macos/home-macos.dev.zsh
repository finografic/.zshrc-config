export REPOS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="echo 'CHOOSE AN ALIAS!'"

# COMMANDS

function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$REPOS" && l
}

npmi() {
  if [[ -n "$@" ]]; then
    # ARGS PASSED: INSTALL PACKAGES AND UPDATE package-lock.json
    git update-index --no-assume-unchanged -- package-lock.json
    npm install $@
    git status
  else
    # NO ARGS: INSTALL DEFAULT PACKAGES TEMP IGNORE package-lock.json
    npm install
    git update-index --assume-unchanged -- package-lock.json
    git status
  fi
}

_gclean__ORIG() {
  [ ! -d "./.git" ] && return
  echo "\n${_y}CLEAN / DELETE LOCAL GIT BRANCHES.. sure to proceed? (y/n)\n${_0}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "\n${_grey}Proceeding to delete local branches..\n${_0}"
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
  else
    echo "Operation aborted."
    exit 1
  fi
}

_gclean() {
  local pattern=$1
  [ ! -d "./.git" ] && return

  if [ -z "$pattern" ]; then
    echo "\n${_y}Error: Please provide a pattern (e.g., 'T*' for branches starting with T)\n${_0}"
    return 1
  fi

  echo "\n${_y}CLEAN / DELETE LOCAL GIT BRANCHES MATCHING '$pattern'.. sure to proceed? (y/n)\n${_0}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "\n${_grey}Proceeding to delete local branches matching '$pattern'..\n${_0}"
    git branch --merged | grep -E "^[[:space:]]*$pattern$" | xargs git branch -d
  else
    echo "Operation aborted."
    return 1
  fi
}

# ========================================================================= #
# NOTE: APNAES - RSYNC TRANSFERS, BACKUPS, and PUBLISHING..

export ROOT_ACCESS="root@REDACTED-IP"
export REMOTE_LSWS="/usr/local/lsws"

export LOCAL_WEB="$HOME/repos-apnaes/apnaes-web"
export LOCAL_API="$HOME/repos-apnaes/apnaes-api"
export REMOTE_WEB="/usr/local/lsws/Example"
export REMOTE_API="/usr/local/lsws/api"

# REMOTE: HOSTING
# alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"
alias h="ssh -i ~/.ssh/id_hostinger.pub -p 22 $ROOT_ACCESS"
alias a="ssh -i ~/.ssh/id_hostinger.pub -p 22 apnaes@REDACTED-IP"

h_get_all() {
  echo "${_c}\nDownloading FULL 'lsws' folder + contents from remote...\n${_0}"
  rsync -avz --progress -e "ssh -p 22" $ROOT_ACCESS:/usr/local/lsws ~/Public

  echo "${_g}\nfull 'lsws' folder downloaded to ~/Public\n${_0}"
}

h_pub_web() {
  echo "${_y}\nPublishing WEB: LOCAL -> REMOTE...\n${_0}"
  rsync -avz --progress --no-perms --no-owner --no-group $LOCAL_WEB/dist/ $ROOT_ACCESS:$REMOTE_WEB/html/

  echo "${_grey}\nweb 'html' content published to remote.\n${_0}"
}

# ========================================================================= #
