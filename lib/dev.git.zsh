##################################
###########  GIT DEV  ############
##################################

# Git prompt styling
source "$ZSHRC_ROOT/themes/prompt.zsh"

# GIT STATUS
_g() {
  # RESET GIT PERMISSIONS
  # own .git
  # sudo chgrp -R ${USER} .git/objects
  # sudo chmod -R g+rws .git/objects
  # GIT STATUS
  git status
}


# GIT LOG, BUT PRETTY-PRINTED !!
_glog() {
  git log --graph --abbrev-commit --decorate --date=relative --all
}

_grm(){
  if [[ $1 > "" ]]; then
   git rm --cached "$1"
  else
    echo "\n${_y}⚠️   NO FILE SPECIFIED TO UN-TRACK\n"
  fi
}

checkout() {
  # REQUIRES NPM PACKAGE: git-branch-select
  # https://www.npmjs.com/package/git-branch-select
  git branch-select -l
}

master() {
  git checkout master
  # NOTE: OPT-OUT auto ci build
  # [[ "$1" != "--skip" ]] && npm ci;
  # NOTE: OPT-IN auto ci build
  [[ "$1" == "ci" ]] && npm ci
}

# Function to get the current git branch
_current_git_branch() {
  git branch --show-current
}

branch__V1() {
  if [[ $1 > "" ]]; then
    NEW_BRANCH="$1"
    # REPLACE: FOR OPTIONAL "SBS-" PREFIX
    git checkout -b "SBS-${NEW_BRANCH}"
  else
    git branch-select -l
  fi
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

rebase() {
  git rebase i origin/master
}

commit() {
  if [[ $1 > "" ]]; then
    message="$1"
    git add .
    git commit -m "$message" --no-verify
  else
    echo "\n${_y}⚠️   NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# TODO: THIS CAUSES *HOT* ERROR (without hitting Enter):
# "Fatal: No rebase in progress..." - WHY / HOW is this HOT ?????
# function continue() {
#   git rebase --continue
# }

# GIT USER (SILENT)

# function _pr() {
#   # USEING GITHUB DESKTOP
#   gh pr checkout $1;
# };

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

# NEW: GIT COMMIT (already staged files only)
_gc() {
  if [[ -n "$1" ]]; then
    message="$1"

    git commit -m "$message"
    echo "\n${_g}✅ DONE\n"
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# NEW: GIT COMMIT ALL (stages files first, then commits)
_gca() {
  if [[ -n "$1" ]]; then
    message="$1"

    # Only run git add . if not in office environment
    if [[ "$ZENV" != "office-macos" ]]; then
      git add .
    fi

    git commit -m "$message"
    echo "\n${_g}✅ DONE\n"
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# Function to fetch and rebase, then push if no conflicts
_gpl__v1() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  local CURRENT_GIT_BRANCH=$(_current_git_branch)

  git fetch && git rebase origin/master

  if [ $? -eq 0 ]; then
    echo -e "\033[0;35mAbout to --force-with-lease $CURRENT_GIT_BRANCH to origin/master..\nAre you sure? (y/n)\033[0m"
    read -r response
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

# Function to fetch and rebase, then push if no conflicts
_gpl__V2() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  local CURRENT_GIT_BRANCH=$(_current_git_branch)

  # Fetch and rebase with squash
  git fetch && git rebase -i origin/master

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

# Function to fetch and rebase, then push if no conflicts
_gpl() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Fetch and rebase with squash
  git fetch
  local CURRENT_GIT_BRANCH=$(_current_git_branch)
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

# GIT FETCH + PULL
_gf() {
  [ ! -d "./.git" ] && return
  echo "\n${_m}fetching and pulling..\n${_0}"
  git fetch
  git pull
}

# GIT RESET HEAD with ORIGIN
_gro() {
  [ ! -d "./.git" ] && return
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

# GIT CHECKOUT PR + NPM CI
pr() {
  gh pr checkout $1
  npm ci
}

if [ $ZENV != "office-macos" ]; then
  git config --global color.ui true
  git config --global user.name "Justin"
  git config --global user.email "justin.blair.rankin@gmail.com"
  git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!
fi