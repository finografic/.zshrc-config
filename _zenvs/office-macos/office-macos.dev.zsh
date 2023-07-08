# MAIN REPOS / PRJOECTS FOLDER
export PROJECTS_REPORTING="$HOME/repos-reporting"
export PROJECTS_SBC="$HOME/repos-sbc"

# CURRENT REPO - THIS WILL BE REPLACED WITH A NEW SCRIPT :D
REPO_CURRENT="$PROJECTS_REPORTING/sbc.accounting.reporting.ui";

# PROJECTS_REPORTING
alias repos="cd $PROJECTS_REPORTING && l";
alias sbc="cd $PROJECTS_SBC && l";
alias repo="cd $REPO_CURRENT && l";
alias misc="cd $HOME/repos-misc && l";
alias apps="cd $HOME/repos-apps && l";
alias my="cd $HOME/repos-my && l";

# MIRO REPOS
alias rui="cd $PROJECTS_REPORTING/sbc.accounting.reporting.ui/ && l";
alias admin="cd $PROJECTS_SBC/sbc.core.support.ui/ && l";
alias dash="cd $PROJECTS_SBC/sbc.accounting.dashboard.ui/ && l";
alias poc="cd $PROJECTS_REPORTING/sbc.poc.data-visualization.ui/ && l";

# SBC REPOS (others..)
alias carbon="cd $PROJECTS_SBC/carbon/ && l";
alias tokens="cd $PROJECTS_SBC/design-tokens/ && l";
alias cm="cd $PROJECTS_SBC/sbc.accountants.clientmanagement.ui/ && l";
alias notes="cd $PROJECTS_SBC/sbc.common.notes.ui/ && l";
alias tui="cd $PROJECTS_SBC/sbc.template.ui/ && l";
alias org="cd $PROJECTS_SBC/sbc.core.orghub.ui/ && l";
alias aui="cd $PROJECTS_SBC/sbc.accounting.ui/ && l";
alias cui="cd $PROJECTS_SBC/sbc.accounting.compliance.ui/ && l";
alias acc="cd $PROJECTS_SBC/sbc.accounting.accounts.ui/ && l";

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# LOUPEDECK
function loupe() {
 cd $HOME/.local/share/Loupedeck;
  # exa --long --all --group-directories-first --accessed --time-style=long-iso --git $1

  # NOTE: BELOW - COMMENTED-OUT, DUE TO LONG PROCESS TIMES :()
  # EXA_IGNORES=".DS_Store|Icon*|.directory";
  # exa --long --all --ignore-glob="${EXA_IGNORES}" --group-directories-first --accessed --time-style=long-iso --git $1
  # [ -d .git ] && git status -uno;
}
alias luup=loupe;
alias l2="cd $HOME/.local/share && l";

# COMMANDS
function repos() {
    # msg err "PLEASE USE ALIAS 'dev'" # zsh
    # use my MSG FUNCTION
    # MOVED !!
    cd "$PROJECTS_REPORTING" && l;
}

# TIME-SAVERS
function prep() {
  npm ci;
  npm run format;
  npm run lint;
  npm run test:coverage;
}

function bots() {
  # CM USES LABELS TO ALLOW THIS... OTHER METHODS EXIST
  if [[ $@ == "--json" ]];
    then gh pr list --label dependencies --json number,title,url;
    else gh pr list --label dependencies;
  fi

  # gh pr list --label dependencies --search "status:success review:required"
}

# JEST - UNIT TESTING ALIAS !!!
function j() {
  if [[ "$2" > "" ]] then
      jest --config="./jest.config.js" "$1" --watch -t "$2";
  elif [[ "$1" > "" ]] then
      jest --config="./jest.config.js" "$1" --watch;
  else
      npm run test:coverage -- --maxWorkers=2
  fi
}

# JEST - CLEAR CACHE ON INIT
jest --clearCache

# ============================================================================ #

# USAGE
#   gh pr list [flags]
#
# FLAGS
#       --app string        Filter by GitHub App author
#   -a, --assignee string   Filter by assignee
#   -A, --author string     Filter by author
#   -B, --base string       Filter by base branch
#   -d, --draft             Filter by draft state
#   -H, --head string       Filter by head branch
#   -q, --jq expression     Filter JSON output using a jq expression
#       --json fields       Output JSON with the specified fields
#   -l, --label strings     Filter by label
#   -L, --limit int         Maximum number of items to fetch (default 30)
#   -S, --search query      Search pull requests with query
#   -s, --state string      Filter by state: {open|closed|merged|all} (default "open")
#   -t, --template string   Format JSON output using a Go template
#   -w, --web               List pull requests in the web browser
#
# INHERITED FLAGS
#       --help                     Show help for command
#   -R, --repo [HOST/]OWNER/REPO   Select another repository using the [HOST/]OWNER/REPO format
#
# EXAMPLES
#   List PRs authored by you
#   $ gh pr list --author "@me"
#
#   List only PRs with all of the given labels
#   $ gh pr list --label bug --label "priority 1"
#
#   Filter PRs using search syntax
#   $ gh pr list --search "status:success review:required"
#
#   Find a PR that introduced a given commit
#   $ gh pr list --search "<SHA>" --state merged
