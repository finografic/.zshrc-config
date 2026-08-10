# ============================================================================ #
# REBASE AND MERGE OPERATIONS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

# Fetch and rebase
# Usage: _grb [-y]
#   -y  Non-interactive rebase (skips editor) and auto-accepts force-push
function _grb() {
  local auto=0
  [[ "$1" == "-y" ]] && { auto=1; shift; }

  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Ensure origin/master exists
  if ! git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "\n${_y}⚠️  Missing origin/master. This repo may not use master as the base branch.${_0}"
    return 1
  fi

  # Fetch and "pull" origin/master into local master (without leaving current branch)
  # This is effectively: checkout master; git pull --ff-only origin master
  git fetch origin master:master

  # Rebase current feature branch onto the updated remote base
  if (( auto )); then
    git rebase origin/master
  else
    git rebase -i origin/master
  fi

  # Exit if rebase fails
  if [[ $? -ne 0 ]]; then
    echo "\n${_y}⚠️  Rebase conflicts detected. Resolve them before proceeding.${_0}"
    return 1
  fi

  # Get the current branch name
  local CURRENT_BRANCH=$(_gcurrent)

  # Prompt for force-push (skipped with -y)
  if (( auto )); then
    git push -u origin "$CURRENT_BRANCH" --force-with-lease
    echo "\n${_g}✅ Force-push complete.${_0}"
  else
    echo -e "\n${_m}Force-push with lease $CURRENT_BRANCH to origin? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}

    if [[ "$response" =~ ^[Yy]$ ]]; then
      git push -u origin "$CURRENT_BRANCH" --force-with-lease
      echo "\n${_g}✅ Force-push complete.${_0}"
    else
      echo "\n${_grey}Force-push aborted.${_0}"
    fi
  fi
}

# Fetch, rebase, and push with squash
function _grbs() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Fetch and rebase with squash
  git fetch
  local CURRENT_BRANCH=$(_gcurrent)
  local COMMIT_COUNT=$(git rev-list --count origin/master..HEAD)

  if [[ "$COMMIT_COUNT" -gt 1 ]]; then
    # export EDITOR="sed -i -e '/^# This is the [2-9].*commit message:/,/^#$/d'"
    # If more than 1 commit, do an automatic rebase with squash
    GIT_SEQUENCE_EDITOR="sed -i -e '2,\$s/^pick/squash/'" git rebase -i origin/master
  elif [[ "$COMMIT_COUNT" -eq 1 ]]; then
    # If only 1 commit, just do a regular rebase
    git rebase origin/master
  else
    echo "No commits to rebase"
  fi

  # git rebase -i origin/master
  if [[ $? -eq 0 ]]; then
    echo -e "\n${_m}Force-push with lease $CURRENT_BRANCH to origin? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-Y}
    if [[ "$response" =~ ^[Yy]$ ]]; then
      git push -u origin "$CURRENT_BRANCH" --force-with-lease
      echo "\n${_g}✅ DONE${_0}\n"
    else
      echo "\n${_y}⚠️  Aborted."
    fi
  else
    echo "\n${_y}⚠️  Rebase conflicts detected. Resolve them before pushing."
  fi
}

# ============================================================================ #

# Merge a feature branch into master via rebase + fast-forward only.
# Rebases <branch> onto master first (linearizes it, individual commits kept
# as-is), then fast-forwards master onto the rebased tip. No merge commit is
# ever created, so the resulting history on master is freely squashable,
# revertable, and reorderable later — nothing to untangle.
#
# Usage: _gmff <branch> [-y]
#   -y  Non-interactive: auto-confirms push + branch deletion
function _gmff() {
  local branch=""
  local auto=0

  for arg in "$@"; do
    if [[ "$arg" == "-y" ]]; then
      auto=1
    else
      branch="$arg"
    fi
  done

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\n${_y}⚠️  Not inside a git repository.${_0}"
    return 1
  fi

  if [[ -z "$branch" ]]; then
    echo "\n${_y}⚠️  No feature branch specified${_0}"
    echo "${_grey}Usage:${_0} _gmff <branch> [-y]\n"
    return 1
  fi

  local CURRENT_BRANCH=$(_gcurrent)
  if [[ "$CURRENT_BRANCH" != "master" ]]; then
    echo "\n${_y}⚠️  _gmff must be run from master (currently on '${CURRENT_BRANCH}')${_0}"
    return 1
  fi

  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "\n${_r}❌ Branch '$branch' does not exist${_0}"
    return 1
  fi

  if [[ -n "$(git status --porcelain)" ]]; then
    echo "\n${_y}⚠️  Uncommitted changes on master. Commit or stash before running _gmff.${_0}"
    return 1
  fi

  # Keep local master current with origin before rebasing onto it, if a remote exists
  if git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "\n${_grey}Updating local master from origin...${_0}"
    if ! git pull --ff-only origin master; then
      echo "\n${_r}❌ Could not fast-forward master from origin. Resolve manually first.${_0}"
      return 1
    fi
  fi

  echo "\n${_m}Rebasing '${branch}' onto master...${_0}"
  git checkout "$branch" || return 1

  if ! git rebase master; then
    echo "\n${_y}⚠️  Rebase conflicts on '${branch}'. Resolve them, then re-run: _gmff ${branch}${_0}"
    return 1
  fi

  echo "\n${_m}Fast-forwarding master to '${branch}'...${_0}"
  git checkout master || return 1

  if ! git merge --ff-only "$branch"; then
    echo "\n${_r}❌ Fast-forward failed unexpectedly after rebase. Aborting.${_0}"
    return 1
  fi

  echo "\n${_g}✅ master now includes '${branch}' — fast-forward only, no merge commit, full history kept.${_0}"

  if (( auto )); then
    git push origin master
  else
    echo "\n${_m}Push master to origin? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}
    if [[ "$response" =~ ^[Yy]$ ]]; then
      git push origin master
    else
      echo "\n${_grey}Push skipped.${_0}"
    fi
  fi

  if (( auto )); then
    git branch -d "$branch"
    echo "${_g}✅ Deleted local branch '${branch}'${_0}"
  else
    echo "\n${_m}Delete local branch '${branch}'? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}
    if [[ "$response" =~ ^[Yy]$ ]]; then
      git branch -d "$branch"
      echo "${_g}✅ Deleted local branch '${branch}'${_0}"
    else
      echo "\n${_grey}Branch kept.${_0}"
    fi
  fi
}
