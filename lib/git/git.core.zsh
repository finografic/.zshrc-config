# ============================================================================ #
# CORE GIT OPERATIONS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

function git-root() {
  git rev-parse --show-toplevel 2>/dev/null
}

function is-git-root() {
  local root
  root="$(git-root)" || return 1
  [[ "$PWD" == "$root" ]]
}

# The branch feature work is rebased onto and merged into.
#
# Reads $PROFILE_GIT_BASE_BRANCH (set per profile — office-macos uses "main")
# and falls back to "master" when unset or empty. The fallback lives here and
# only here, so no caller has to know the var exists and nothing depends on it
# being set: an unconfigured shell behaves exactly as it did before.
#
# Lives in git.core.zsh rather than git.rebase.zsh because consumers now span
# modules (rebase, checkout). Core is sourced by the git feature regardless, so
# there is no load-order dependency between sibling modules.
function git-base-branch() {
  print -r -- "${PROFILE_GIT_BASE_BRANCH:-master}"
}

# Checkout the profile's base branch — master at home, main at the office.
# Use this in muscle memory and scripts; `master` and `main` below stay as
# literal escape hatches for repos that disagree with the profile.
function base() {
  git checkout "$(git-base-branch)"
}

# Checkout master
function master() {
  git checkout master
}

# Checkout main
function main() {
  git checkout main
}

# Basic checkout/status
function _g() {
  if [[ -z "$1" ]]; then
    git status
  else
    git checkout "$1" && git status
  fi
}

# New branch checkout
function _gb() {
  if [[ -n "$1" ]]; then
    local branch="$1"
    # NOTE: DO NOT AUTO-ADD FOR OFFICE..
    [[ "$ZENV" != "office-macos" ]] && git add .
    git checkout -b "$branch"
  else
    echo "\n${_y}⚠️   NO BRANCH NAME SUPPLIED\n"
    checkout # git branch-select
  fi
}

# Get current branch
function _gcurrent() {
  git branch --show-current
}

# Fetch and pull
function _gf() {
  if ! git-root >/dev/null; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi
  echo "\n${_m}fetching and pulling..\n${_0}"
  git fetch
  git pull
}

# GitHub PR checkout
function _gpr() {
  gh pr checkout $1
  npm ci
}


# CREATE / APPLY PATCH  (_gpatch [apply [name]])
function _gpatch() {
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
alias .="git status"
alias s="git status"

# Git identity is a one-time machine-setup step, not a shell-start step.
# Run scripts/setup/configure-git-identity.zsh once per machine instead.
