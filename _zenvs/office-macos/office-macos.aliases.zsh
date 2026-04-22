REPOS_MY="$HOME/repos-my"

alias _aws="aws sso login"

_select() {
  gli select
}


# ============================================================== #

@release() {
  cd "$REPOS_GAC/s1_config"
  git checkout release
  l
  # NOTE:
  # 1. ./vbump.sh -p -e preprod -v 5.243.1
  # 2. ./vbump.sh -e production -v 5.243.1
  # 3. ./vbump.sh -e qa_base_config -v 5.243.1
}

# ============================================================== #
# NOTE: PERSONAL

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="echo '${_y}CHOOSE AN ALIAS!${_0}'"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'

@my() {
  cd "$HOME/repos-my" && l
}

@_gli() {
  cd "$REPOS_MY/@finografic-gli" && l
}

@_lay() {
  cd "$REPOS_MY/macos-layouts" && l
}

# ============================================================== #
# NOTE: GENERATED ALIASES - (SEE .env FOR CONFIGURATION)
# Optional `.env` source of truth.
# Use full paths as values so local folder layout stays out of tracked files:

_register_office_repo_aliases() {
  (( ${+OFFICE_REPO_ALIASES} )) || return 0

  local alias_name target_path
  for alias_name target_path in ${(kv)OFFICE_REPO_ALIASES}; do
    eval "alias ${alias_name}='cd ${target_path:q} && l'"
  done
}

_register_office_repo_aliases
unset -f _register_office_repo_aliases
