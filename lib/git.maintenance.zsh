# ========================================================================= #
# MAINTENANCE OPERATIONS
# ========================================================================= #

# Clean (delete multiple branches)
_gclean() {
  if [[ -z "$1" ]]; then
    echo "\n${_y}⚠️  No branch pattern specified\n${_0}"
    return 1
  fi

  local GLOB_ARG="$1"
  local AFFECTED_BRANCHES=$(git branch | grep "$GLOB_ARG" || true)

  if [[ -z "$AFFECTED_BRANCHES" ]]; then
    echo "\n${_y}⚠️  No branches found matching '$GLOB_ARG'\n${_0}"
    return 1
  fi

  echo "\n\n${_grey}${_B}Using '${_y}${_B}${GLOB_ARG}${_grey}${_B}*' will ${_y}${_B}DELETE${_grey}${_B} the following branches:${_0}\n"
  echo "${_y}$AFFECTED_BRANCHES${_0}\n"

  # Get preserved branches by excluding the deletion pattern
  local BASE_PATTERN=${GLOB_ARG%[0-9]*} # Remove numbers and everything after
  local PRESERVED_BRANCHES=$(git branch | grep "$BASE_PATTERN" | grep -v "$GLOB_ARG" || true)

  if [[ ! -z "$PRESERVED_BRANCHES" ]]; then
    echo "${_grey}${_B}Preserves the following branches:${_0}\n"
    echo "${_c}$PRESERVED_BRANCHES${_0}\n"
  fi

  echo "${_r}⚠️   Are you sure you want to DELETE these branches? ${_grey}(y/N)${_0}\n"
  read -r response
  response=${response:-N}

  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "\n${_grey}Deleting branches...${_0}"
    git branch | grep "$GLOB_ARG" | xargs git branch -D
    echo "\n${_g}✅ Branch cleanup complete${_0}\n"
  else
    echo "\n${_y}Operation aborted${_0}\n"
  fi
}

# ================================================================== #
# NOTE: CLEAUP ALL STASHES

# Clear all git stashes
_gtrashes() {
  local STASH_COUNT=$(git stash list | wc -l | tr -d ' ')

  echo "\n${_r}⚠️  WARNING: This will DELETE ALL ${_y}${STASH_COUNT}${_r} stashes!${_0}"
  echo "\n${_grey}Preview of stashes to be deleted:${_0}"
  git stash list | head -n 5

  [[ $STASH_COUNT -gt 5 ]] && echo "${_grey}... and ${_y}$((STASH_COUNT - 5))${_grey} more stashes${_0}"

  echo "\n${_r}Are you absolutely sure you want to delete all stashes? ${_grey}(y/N)${_0}\n"
  read -r response
  response=${response:-N}

  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "\n${_grey}Clearing all stashes...${_0}"
    git stash clear
    echo "\n${_g}✅ All stashes have been cleared${_0}\n"
  else
    echo "\n${_y}Operation aborted${_0}\n"
  fi
}

# ================================================================== #

# Pretty-printed git log
_glog() {
  git log --graph --abbrev-commit --decorate --date=relative --all
}

# Reset HEAD with origin
_greset_origin() {
  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi
  echo "\n${_y}RESET HEAD with Origin.. sure to proceed? (y/n)\n${_0}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "\n${_grey}Proceeding to reset head with origin..\n${_0}"
    git fetch origin
    git reset --hard origin/HEAD
  else
    echo "Operation aborted."
    exit 1
  fi
}

# Reset to specific commit
_greset() {
  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi

  if [[ -z "$1" ]]; then
    echo "\n${_y}⚠️  No commit hash provided\n${_0}"
    return 1
  fi

  # Check if hash exists and get commit details
  if commit_info=$(git show --no-patch --format="%H%n%an <%ae>%n%ad%n%n    %s" "$1" 2>/dev/null); then
    echo "\n${_m}Found commit:${_0}\n"
    echo "$commit_info\n"

    echo "${_y}Reset HEAD to this commit? ${_grey}(y/N)${_0}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "\n${_grey}Resetting to commit $1..${_0}"
      git reset --hard "$1"
      echo "\n${_g}✅ Reset complete${_0}"
    else
      echo "\n${_y}Operation aborted.${_0}"
    fi
  else
    echo "\n${_r}❌ Invalid commit hash or commit not found${_0}"
    return 1
  fi
}

# Reset git permissions
_g_PERMISSIONS() {
  # TODO: ??
  # RESET GIT PERMISSIONS
  # own .git
  # sudo chgrp -R ${USER} .git/objects
  # sudo chmod -R g+rws .git/objects
  # GIT STATUS
  git status
}

alias glog=""
