# ========================================================================= #
# CORE GIT OPERATIONS
# ========================================================================= #

# Checkout master
master() {
  git checkout master
  [[ "$1" == "ci" ]] && npm ci
}

# Basic checkout/status
_g() {
  if [[ -z "$1" ]]; then
    git status
  else
    git checkout "$1" && git status
  fi
}

# New branch checkout
_gb() {
  if [[ $1 > "" ]]; then
    branch="$1"
    # NOTE: DO NOT AUTO-ADD FOR OFFICE..
    [ $ZENV != "office-macos" ] && git add .
    git checkout -b "$branch"
  else
    echo "\n${_y}⚠️   NO BRANCH NAME SUPPLIED\n"
    checkout # git branch-select
  fi
}

# Get current branch
_gcurrent() {
  git branch --show-current
}

# Fetch and pull
_gf() {
  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi
  echo "\n${_m}fetching and pulling..\n${_0}"
  git fetch
  git pull
}

# GitHub PR checkout
_gpr() {
  gh pr checkout $1
  npm ci
}


# CREATE / APPLY PATCH  (_gpatch [apply [name]])
_gpatch() {
  if [[ "$1" == "apply" ]]; then
    local patchfile="${${2:-CHANGES}%.patch}.patch"
    if [[ ! -f "$patchfile" ]]; then
      echo "\n${_y}⚠️  Patch file not found: ${patchfile}\n${_0}"
      return 1
    fi
    git apply --whitespace=fix "$patchfile" && return 0
    echo "\n${_y}⚠️  Direct apply failed — retrying with 3-way merge...\n${_0}"
    git apply -3 --whitespace=fix "$patchfile"
  else
    local outfile="${${1:-CHANGES}%.patch}.patch"
    git diff HEAD --binary > "$outfile"
    if [[ $? -ne 0 ]]; then
      echo "\n${_y}⚠️  Patch creation failed\n${_0}"
      rm -f "$outfile"
      return 1
    elif [[ ! -s "$outfile" ]]; then
      echo "\n${_y}⚠️  No changes to patch\n${_0}"
      rm -f "$outfile"
      return 1
    fi
    echo "\n patch made: ${_g}${outfile}\n${_0}"
  fi
}

# Common aliases
alias b="branch"
alias .="git status"
alias s="git status"

# Git config (non-office only)
if [ $ZENV != "office-macos" ]; then
  git config --global color.ui true
  git config --global user.name "Justin"
  git config --global user.email "justin.blair.rankin@gmail.com"
  git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!
fi

