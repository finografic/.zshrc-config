export PROJECTS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

# SAGE REPOS
# alias cc="cd $PROJECTS/sbc.common.compliancecentre.ui/ && l";
alias ca="cd $PROJECTS/sbc.accounting.ui/ && l";
alias cc="cd $PROJECTS/sbc.accounting.compliance.ui/ && l";
alias cm="cd $PROJECTS/sbc.accountants.clientmanagement.ui/ && l";
alias notes="cd $PROJECTS/sbc.common.notes.ui/ && l";

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
