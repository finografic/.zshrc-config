# ============================================================================ #
# NODE GLOBALS - npm/global-package version helpers
# ============================================================================ #

alias kn='killall -9 node'

# Package manager of choice
alias i="pnpm install"

# ALIASES THAT TAKE PARAMETERS
function versions() {
  # ALL THE SAME ??
  npm view "$1" versions --json
  # npm info "$1" versions --json
  # npm show "$1" versions --json
  # yarn info "$1" versions
}

# NPM - GET PACKAGE VERSION
function v() {
  CURRENT_VERSION=$($1 --version)
  LATEST_VERSION=$(latest-version $1)
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:"
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION"
  else
    echo "\e[1mCurrent version of \e[1m\e[36m$1\e[0m is up to date."
    echo "\e[32m\e[1m$CURRENT_VERSION"
  fi
}

function latest() {
  latest-version $1
}

function update() {
  # GET VERSIONS
  CURRENT_VERSION=$($1 --version)
  LATEST_VERSION=$(latest-version $1)

  # OUTPUT INFO
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:"
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION"
  else
    echo "\e[0mCurrent version of \e[1m\e[36m$1\e[0m is latest version."
    echo "\e[32m\e[1m$CURRENT_VERSION"
  fi

  # UPDATE ??
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\n\e[0mUpdating global package \e[1m\e[36m$1\e[1m\e[0m ...\n"
    npm i -g $1@$LATEST_VERSION
  fi
}
