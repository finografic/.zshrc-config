# ========================================================================= #
# REBASE AND MERGE OPERATIONS
# ========================================================================= #

# Fetch and rebase
_grb() {
  # Fetch and rebase
  git fetch && git rebase -i origin/master

  # Exit if rebase fails
  if [ $? -ne 0 ]; then
    echo "\n${_y}⚠️  Rebase conflicts detected. Resolve them before proceeding.${_0}"
    return 1
  fi

  # Get the current branch name
  local CURRENT_BRANCH=$(_gcurrent)

  # Prompt for force-push
  echo -e "\n${_m}Force-push with lease $CURRENT_BRANCH to origin? ${_grey}(y/N)${_0}"
  read -r response
  response=${response:-N}

  if [[ "$response" =~ ^[Yy]$ ]]; then
    git push -u origin "$CURRENT_BRANCH" --force-with-lease
    echo "\n${_g}✅ Force-push complete.${_0}"
  else
    echo "\n${_y}⚠️  Force-push aborted.${_0}"
  fi
}

# Fetch, rebase, and push with squash
_grbs() {
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
      echo "\n${_g}✅ DONE\n"
    else
      echo "\n${_y}⚠️  Aborted."
    fi
  else
    echo "\n${_y}⚠️  Rebase conflicts detected. Resolve them before pushing."
  fi
}

# Merge into master (alternative - overwrites master with source branch)
_gmm() {
  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi

  if [[ -z "$1" ]]; then
    echo "\n${_y}⚠️  No source branch specified\n${_0}"
    return 1
  fi

  local SOURCE_BRANCH="$1"
  local TARGET_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Check if source branch exists
  if ! git rev-parse --verify "$SOURCE_BRANCH" >/dev/null 2>&1; then
    echo "\n${_r}❌ Source branch '$SOURCE_BRANCH' does not exist${_0}"
    return 1
  fi

  echo "\n${_y}⚠️  WARNING: This will completely overwrite '$TARGET_BRANCH' with contents from '$SOURCE_BRANCH'${_0}"
  echo "${_y}⚠️  All files in '$TARGET_BRANCH' will be replaced with files from '$SOURCE_BRANCH'${_0}"
  echo "\n${_m}Are you sure? ${_grey}(y/N)${_0}"
  read -r response

  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "\n${_grey}Proceeding with overwrite...${_0}"

    # Stash any uncommitted changes
    git stash push -m "Temporary stash before branch overwrite"

    # Hard reset to source branch
    if ! git reset --hard "$SOURCE_BRANCH"; then
      echo "\n${_r}❌ Failed to reset to $SOURCE_BRANCH${_0}"
      return 1
    fi

    echo "\n${_g}✅ Successfully overwrote $TARGET_BRANCH with contents of $SOURCE_BRANCH${_0}"
    echo "${_m}To push these changes to remote, use: git push -f origin $TARGET_BRANCH${_0}"
  else
    echo "\n${_y}Operation aborted.${_0}"
    return 1
  fi
}
