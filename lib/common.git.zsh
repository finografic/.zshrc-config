
##################################
###########  GIT DEV  ############
##################################

function master() {
  git checkout master;
  # NOTE: OPT-OUT auto ci build
  # [[ "$1" != "--skip" ]] && npm ci;
  # NOTE: OPT-IN auto ci build
  [[ "$1" == "ci" ]] && npm ci;
}

function checkout() {
  # REQUIRES NPM PACKAGE: git-branch-select
  # https://www.npmjs.com/package/git-branch-select
  git branch-select -l
}

function branch__V1() {
  if [[ $1 > "" ]] then
      NEW_BRANCH="$1"
      # REPLACE: FOR OPTIONAL "SBS-" PREFIX
      git checkout -b "SBS-${NEW_BRANCH}"
  else
      git branch-select -l
  fi
}

function branch() {
  if [[ $1 > "" ]] then
      NEW_BRANCH="SBS-${1}"
      git checkout -b "${NEW_BRANCH/SBS-SBS/"SBS"}"
  else
      git branch-select -l
  fi
}

function rebase() {
  git rebase i origin/master
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

function _gs() {
    # RESET GIT PERMISSIONS
    # own .git
    # sudo chgrp -R ${USER} .git/objects
    # sudo chmod -R g+rws .git/objects
    # GIT STATUS
    git status
}

function _gb() {
  if [[ $1 > "" ]] then
      branch="$1"
      # git add . # NOTE: REMOVED FROM THIS COMMON / SHARED INSTANCE OF _gc
      git checkout -b "$branch"
  else
    echo "\n${_y}⚠️   NO BRANCH NAME SUPPLIED\n";
    checkout  # git branch-select
  fi
}

function _go() {
    # ALT (ORIG) git branch-select
    git checkout $1
}

function _gc() {
  if [[ $1 > "" ]] then
      message="$1"
      # git add . # NOTE: REMOVED FROM THIS COMMON / SHARED INSTANCE OF _gc
      git commit -m "$message"
  else
    echo "\n${_y}⚠️   NO COMMIT MESSAGE SUPPLIED\n";
  fi
}

function pr() {
  gh pr checkout $1;
  npm ci;
};

# "glog" - GIT LOG, BUT PRETTY-PRINTED !!
alias glog='git log --graph --abbrev-commit --decorate --date=relative --all'
alias b="branch"
alias .="git status"
alias s="git status"
