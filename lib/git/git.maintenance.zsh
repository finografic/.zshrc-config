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

# ============================================================================ #

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

# ============================================================================ #

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

# ============================================================================ #

# Rename initial commit message
_grename_initial() {

  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository${_0}"
    return 1
  fi

  if [[ -z "$1" || "$1" == "--help" || "$1" == "-h" ]]; then
    echo "\n${_m}Rename initial commit message${_0}\n"
    echo "${_y}Usage:${_0} _grename_initial \"New commit message\" [commit-hash]\n"
    echo "${_grey}If no <commit-hash> is provided, the repository's initial commit (root) is used.${_0}\n"
    echo "${_grey}Examples:${_0}\n  _grename_initial \"Fix typo in initial commit\"\n  _grename_initial \"New message\" abcd1234\n"
    echo "${_grey}Notes:${_0}\n  - This command uses 'git-filter-repo' to rewrite history. Install it from:\n    https://github.com/newren/git-filter-repo\n  - After a successful run you must force-push rewritten refs: ${_y}git push --force --all && git push --force --tags${_0}\n"
    return 0
  fi

  local NEW_MSG="$1"
  local TARGET_ARG="$2"

  # Determine target commit: provided or initial commit
  if [[ -z "$TARGET_ARG" ]]; then
    TARGET_ARG=$(git rev-list --max-parents=0 HEAD 2>/dev/null)
  fi

  local TARGET_COMMIT
  if ! TARGET_COMMIT=$(git rev-parse "$TARGET_ARG" 2>/dev/null); then
    echo "\n${_r}❌ Invalid commit hash or commit not found: ${_y}${TARGET_ARG}${_0}\n"
    return 1
  fi

  local CURRENT_MSG
  CURRENT_MSG=$(git show -s --format=%B "$TARGET_COMMIT")

  echo "\n${_m}Found commit:${_0} ${_y}${TARGET_COMMIT}${_0}\n"
  echo "${_grey}Current message:${_0}\n${CURRENT_MSG}\n"
  echo "${_y}New message:${_0}\n${_c}${NEW_MSG}${_0}\n"

  echo "${_r}⚠️  This will REWRITE repository history for all rewritten refs.${_0}"
  echo "${_m}Continue and replace the commit message? ${_grey}(y/N)${_0}\n"
  read -r response
  response=${response:-N}
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "\n${_y}Operation aborted${_0}\n"
    return 1
  fi

  # Ensure git-filter-repo is available
  if ! git filter-repo --help >/dev/null 2>&1; then
    echo "\n${_r}❌ git-filter-repo not found. Please install 'git-filter-repo' and retry.${_0}\n"
    echo "Install: https://github.com/newren/git-filter-repo\n"
    return 1
  fi

  # Base64-encode the message to safely embed arbitrary content
  local BASE64_MSG
  if ! BASE64_MSG=$(printf '%s' "$NEW_MSG" | python3 -c 'import sys,base64 as b; print(b.b64encode(sys.stdin.buffer.read()).decode())' 2>/dev/null); then
    # fallback to system base64
    BASE64_MSG=$(printf '%s' "$NEW_MSG" | base64 | tr -d '\n')
  fi

  # Build commit-callback python snippet
  local CALLBACK
  CALLBACK=$(cat <<PY
import base64
msg = base64.b64decode(b'$BASE64_MSG')
if commit.original_id == b'$TARGET_COMMIT' or len(commit.parents) == 0:
    commit.message = msg
PY
)

  echo "\n${_grey}Running git filter-repo to update commit message...${_0}\n"
  if git filter-repo --force --commit-callback "$CALLBACK"; then
    echo "\n${_g}✅ Initial commit message renamed.${_0}\n"
    echo "${_m}To update remotes, force-push rewritten refs:${_0}\n"
    echo "  ${_y}git push --force --all && git push --force --tags${_0}\n"
  else
    echo "\n${_r}❌ git filter-repo failed. No changes applied.${_0}\n"
    return 1
  fi

}


# ============================================================================ #

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
