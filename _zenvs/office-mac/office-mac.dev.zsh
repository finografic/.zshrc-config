# MAIN REPOS / PRJOECTS FOLDER
export PROJECTS="$HOME/repos"

# CURRENT REPO - THIS WILL BE REPLACED WITH A NEW SCRIPT :D
REPO_CURRENT="$PROJECTS/sbc.accounting.reporting.ui";

# PROJECTS
alias repos="cd $PROJECTS && l";
alias repo="cd $REPO_CURRENT && l";
alias misc="cd $HOME/repos-misc && l";
alias apps="cd $HOME/repos-apps && l";
alias my="cd $HOME/repos-my && l";

# SAGE REPOS (CURRENTLY RELEVANT)
alias tui="cd $PROJECTS/sbc.template.ui/ && l";
alias rui="cd $PROJECTS/sbc.accounting.reporting.ui/ && l";
alias cmui="cd $PROJECTS/sbc.accountants.clientmanagement.ui/ && l";
alias oui="cd $PROJECTS/sbc.core.orghub.ui/ && l";

# SAGE REPOS
alias aui="cd $PROJECTS/sbc.accounting.ui/ && l";
alias cui="cd $PROJECTS/sbc.accounting.compliance.ui/ && l";
alias nui="cd $PROJECTS/sbc.common.notes.ui/ && l";
alias notes="cd $PROJECTS/sbc.common.notes.ui/ && l";

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# COMMANDS

function repos() {
    # msg err "PLEASE USE ALIAS 'dev'" # zsh
    use my MSG FUNCTION
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
