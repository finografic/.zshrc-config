# MY REPOS
REPOS="$HOME/repos"
REPOS_FINO="$HOME/repos-finografic"
REPOS_NEXT="$HOME/repos-next"
REPOS_SERVER="$HOME/repos-server"
REPOS_LOUPEDECK="$HOME/repos-loupedeck"
REPOS_APNAES="$HOME/repos-apnaes"

alias repos="cd $REPOS && l"
alias misc="cd $REPOS/repos-various && l"
alias apps="cd $REPOS/repos-x-apps && l"
alias my="cd $REPOS_FINO && l"
alias json="cd $REPOS_NEXT/json-walker && l"
alias driz="cd $REPOS_SERVER/__DRIZZLE__/api-fastify-drizzle && l"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'

# ========================================================================= #
# MY REPOS (NEXT!)

REPO_ESLINT="$REPOS_FINO/@finografic-eslint-config"
REPO_PLATE="$REPOS_FINO/@finografic-plate-editor"
REPO_APNAES="$REPOS_APNAES/apnaes-monorepo"

REPO_IOX_LOUPEDECK="$REPOS_FINO/iox-loupedeck"
REPO_FNX_MONOREPO="$REPOS_FINO/fnx-monorepo"

alias fnx="cd $REPO_FNX_MONOREPO && l"
alias iox="cd $REPO_IOX_LOUPEDECK && l"

# APNAES
alias apnaes="cd $REPO_APNAES && l"
alias mono="cd $REPO_APNAES && l"
alias admin="cd $REPO_APNAES/apps/client && l"
alias api="cd $REPOS_APNAES/apnaes-api && l"
alias vite="cd $REPOS_APNAES/apnaes-web--VITE && l"

@fino() {
  cd "$REPOS_FINO" && l
}

@eslint() {
  cd "$REPO_ESLINT" && l
}

@plate() {
  cd "$REPO_PLATE" && l
}

# ========================================================================= #
# MONOREPO ALIASES - DETECTS THE MONOREPO PATH USING $PWD

# Helper function to find monorepo ROOT
find_monorepo_root() {
  local current=$PWD
  while [[ $current != "/" ]]; do
    if [[ -f "$current/pnpm-workspace.yaml" ]]; then
      echo "$current"
      return 0
    fi
    current=$(dirname "$current")
  done
  echo "$REPO_APNAES"
  return 1
}

@config() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/config" && l
}

@server() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/apps/server" && l
}

@client() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/apps/client" && l
}

@globals() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/packages/globals" && l
}

@editor() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/packages/plate-editor" && l
}

@i18n() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/packages/i18n" && l
}

@shared() {
  local monorepo=$(find_monorepo_root)
  cd "$monorepo/packages/shared" && l
}

# ========================================================================= #

# COMMON ALIASES
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
