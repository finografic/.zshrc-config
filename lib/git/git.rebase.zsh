# ============================================================================ #
# REBASE AND MERGE OPERATIONS
# ============================================================================ #

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
  if [ $? -ne 0 ]; then
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

  if [ "$COMMIT_COUNT" -gt 1 ]; then
    # export EDITOR="sed -i -e '/^# This is the [2-9].*commit message:/,/^#$/d'"
    # If more than 1 commit, do an automatic rebase with squash
    GIT_SEQUENCE_EDITOR="sed -i -e '2,\$s/^pick/squash/'" git rebase -i origin/master
  elif [ "$COMMIT_COUNT" -eq 1 ]; then
    # If only 1 commit, just do a regular rebase
    git rebase origin/master
  else
    echo "No commits to rebase"
  fi

  # git rebase -i origin/master
  if [ $? -eq 0 ]; then
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
