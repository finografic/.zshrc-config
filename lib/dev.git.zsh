# ========================================================================= #
# GIT DEV
# ========================================================================= #

# NOTE: GIT CHECKOUT BRANCH and/or STATUS (no args = status)

_g() {
  if [[ -z "$1" ]]; then
    git status
  else
    git checkout "$1" && git status
  fi
}

# ========================================================================= #

master() {
  git checkout master
  [[ "$1" == "ci" ]] && npm ci
}

# ========================================================================= #
# REBASE

_grb() {
  git fetch && git rebase -i origin/master
}

# ========================================================================= #
# GIT LOG, BUT PRETTY-PRINTED !!

_glog() {
  git log --graph --abbrev-commit --decorate --date=relative --all
}

# ========================================================================= #

# GIT UNTRACK FILE / FOLDERS
_grm() {
  if [[ $1 > "" ]]; then
    git rm --cached "$1"
  else
    echo "\n${_y}⚠️   NO FILE SPECIFIED TO UN-TRACK\n"
  fi
}

# ========================================================================= #
# Function to get the current git branch

_gcurrent() {
  git branch --show-current
}

branch() {
  if [[ $1 > "" ]]; then
    NEW_BRANCH="SBS-${1}"
    git checkout -b "${NEW_BRANCH/SBS-SBS/"SBS"}"
  else
    git branch-select -l
  fi
}

alias glog=''
alias b="branch"
alias .="git status"
alias s="git status"

# ========================================================================= #
# NEW BRANCH (CHECKOUT)

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

# GIT CHECKOUT
_go() {
  # ALT (ORIG) git branch-select
  git checkout $1
}

# ========================================================================= #

# NEW: GIT COMMIT (already staged files only)
_gc() {
  if [[ -n "$1" ]]; then
    message="$1"
    shift # Remove first argument (message)

    if git commit -m "$message" "$@"; then
      echo "\n${_g}✅ DONE\n"
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# ========================================================================= #
# NEW: GIT ADD ALL + COMMIT (stages files first, then commits)

_gca() {
  if [[ -n "$1" ]]; then
    message="$1"
    shift # Remove first argument (message)

    # Only run git add . if not in office environment
    if [[ "$ZENV" != "office-macos" ]]; then
      git add .
    fi

    if git commit -m "$message" "$@"; then
      echo "\n${_g}✅ DONE\n"
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# ========================================================================= #
# GIT FETCH + PULL

_gf() {
  if [[ ! -d "./.git" ]]; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi
  echo "\n${_m}fetching and pulling..\n${_0}"
  git fetch
  git pull
}

# ========================================================================= #
# Function to fetch and rebase, then push if no conflicts

_gpl() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Fetch and rebase with squash
  git fetch
  local CURRENT_GIT_BRANCH=$(_gcurrent)
  local COMMIT_COUNT=$(git rev-list --count origin/master..HEAD)

  if [ "$COMMIT_COUNT" -gt 1 ]; then
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
    echo -e "\033[0;35mAbout to --force-with-lease $CURRENT_GIT_BRANCH to origin/master..\nAre you sure? (Y/n)\033[0m"
    read -r response
    response=${response:-Y}
    if [[ "$response" =~ ^[Yy]$ ]]; then
      git push -u origin "$CURRENT_GIT_BRANCH" --force-with-lease
      echo "\n${_g}✅ DONE\n"
    else
      echo "\n${_y}⚠️  Aborted."
    fi
  else
    echo "\n${_y}⚠️  Rebase conflicts detected. Resolve them before pushing."
  fi
}

# ========================================================================= #
# NOTE: GIT MERGE INTO MASTER - ALTERNATIVE (OVERWRITES master WITH SOURCE BRANCH)

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
  echo "\n${_m}Are you sure? (y/N)${_0}"
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

# ========================================================================= #
# GIT RESET HEAD with ORIGIN

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

# ========================================================================= #
# GIT RESET TO SPECIFIC COMMIT

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

    echo "${_y}Reset HEAD to this commit? (y/n)${_0}"
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

# ========================================================================= #

# GIT CHECKOUT PR + NPM CI
pr() {
  gh pr checkout $1
  npm ci
}

# ========================================================================= #
# NOTE: SUBMODULE - function to safely push submodule changes and update parent repository

_gps() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Get parent repository path
  local PARENT_REPO=$(git rev-parse --show-superproject-working-tree)
  if [ -z "$PARENT_REPO" ]; then
    echo "⚠️  Warning: This doesn't appear to be a submodule."
    echo "Are you sure you want to continue? (Y/n)"
    read -r response
    response=${response:-Y}
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # Get current branch (should be master for submodules)
  local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Warning: You're not on master branch (current: $CURRENT_BRANCH)"
    echo "Submodules typically use master branch. Continue? (Y/n)"
    read -r response
    response=${response:-Y}
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Commit them first."
    return 1
  fi

  # Push submodule changes
  echo "📦 Pushing submodule changes to origin master..."
  if ! git push origin master; then
    echo "❌ Submodule push failed!"
    return 1
  fi
  echo "✅ Submodule push successful!"

  # If this is a submodule, update parent repository
  if [ -n "$PARENT_REPO" ]; then
    echo -e "\n🔄 Updating parent repository..."

    # Store current path
    local SUBMODULE_PATH=$(git rev-parse --show-prefix)

    # Change to parent repository
    cd "$PARENT_REPO"

    # Add submodule changes
    git add "${SUBMODULE_PATH}"

    # Check if there are changes to commit
    if git diff --cached --quiet; then
      echo "ℹ️  No changes to commit in parent repository"
    else
      # Commit and push if there are changes
      if git commit -m "chore: update eslint-config submodule"; then
        echo "✅ Parent repository commit successful!"

        # Push parent repository changes
        echo -e "\n🚀 Pushing parent repository changes..."
        if git push; then
          echo "✅ Parent repository push successful!"
        else
          echo "❌ Parent repository push failed!"
          return 1
        fi
      else
        echo "❌ Parent repository commit failed!"
        return 1
      fi
    fi
  fi

  echo -e "\n✨ All done! Both submodule and parent repository are up to date."
}

# ========================================================================= #

_g_PERMISSIONS() {
  # TODO: ??
  # RESET GIT PERMISSIONS
  # own .git
  # sudo chgrp -R ${USER} .git/objects
  # sudo chmod -R g+rws .git/objects
  # GIT STATUS
  git status
}

# ========================================================================= #
# ========================================================================= #

if [ $ZENV != "office-macos" ]; then
  git config --global color.ui true
  git config --global user.name "Justin"
  git config --global user.email "justin.blair.rankin@gmail.com"
  git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!
fi
