# MAIN REPOS / PRJOECTS FOLDER
export PROJECTS_REPORTING="$HOME/repos-reporting"

# COMMANDS
function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # zsh
  # use my MSG FUNCTION
  # MOVED !!
  cd "$PROJECTS_REPORTING" && l
}

# TIME-SAVERS
function prep() {
  npm ci
  npm run format
  npm run lint
  npm run test:coverage
}

function confirm() {
  # read -r -p "Are you sure? [y/N] " response
  read -r "Are you sure? [y/N] " response
  response="${response,,}" # tolower
  if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # do_something
    # echo "\n${_g} $response"
    echo "\n $response"
  else
    # do_something_else
    # echo "\n${_r} $response"
    echo "\n $response"
  fi
}

function rebase() {
  CURRENT_GIT_BRANCH="$(git branch --show-current)"
  PREVIOUS_GIT_COMMIT_MESSAGE="$(git log --pretty=format:'%s' -n 1)"

  git add .
  git commit -m "${PREVIOUS_GIT_COMMIT_MESSAGE}" --no-verify
  git fetch && git rebase -i origin/master
  git push -u origin "${CURRENT_GIT_BRANCH}" --force-with-lease
}

function bots() {
  # CM USES LABELS TO ALLOW THIS... OTHER METHODS EXIST
  if [[ $@ == "--json" ]]; then
    gh pr list --label dependencies --json number,title,url
  else
    gh pr list --label dependencies
  fi

  # gh pr list --label dependencies --search "status:success review:required"
}

# JEST - UNIT TESTING ALIAS !!!
function j__ORIG() {
  if [[ "$2" > "" ]]; then
    # jest --config="./jest.config.js" "$1" -t "$2" --runInBand --watch;
    jest --config="./jest.config.js" "$1" -t "$2" --watch
  elif [[ "$1" > "" ]]; then
    # jest --config="./jest.config.js" "$1" --runInBand --watch;
    jest --config="./jest.config.js" "$1" --watch
  else
    npm run test:coverage -- --maxWorkers=2
  fi
}

# JEST - UNIT TESTING ALIAS !!!
function j() {
  if [[ "$2" > "" ]]; then
    # jest --config="./jest.config.js" "$1" -t "$2" --runInBand --watch;
    node 'node_modules/.bin/jest' "$1" -t "$2" --watch
  elif [[ "$1" > "" ]]; then
    # jest --config="./jest.config.js" "$1" --runInBand --watch;
    node 'node_modules/.bin/jest' "$1" --watch
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
