export PROJECTS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# REMOTE: HOSTING
# alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"
alias h="ssh -i ~/.ssh/id_hostinger.pub -p 22 root@REDACTED-IP"
alias a="ssh -i ~/.ssh/id_hostinger.pub -p 22 apnaes@REDACTED-IP"

# COMMANDS

function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$PROJECTS" && l;
}

function npmi() {
  if [[ -n "$@" ]]; then
    # ARGS PASSED: INSTALL PACKAGES AND UPDATE package-lock.json
    git update-index --no-assume-unchanged -- package-lock.json
    npm install $@;
    git status;
  else
    # NO ARGS: INSTALL DEFAULT PACKAGES TEMP IGNORE package-lock.json
    npm install;
    git update-index --assume-unchanged -- package-lock.json;
    git status;
  fi;
}


Apn$134!