# UNIVERSAL ALIASES
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# MY PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

alias api="cd $HOME/repos-apnaes/apnaes-api && l"
alias vite="cd $HOME/repos-apnaes/apnaes-web--VITE && l"
alias json="cd $PROJECTS/repos-dev-next-my/json-walker && l"

alias driz="cd $HOME/repos-db-api-services/__DRIZZLE__/api-fastify-drizzle && l"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'

# ========================================================================= #
# MY PROJECTS (NEXT!)

PROJECTS_MY_NEXT="$HOME/repos-my-next"
PROJECT_IOX_LOUPEDECK="$HOME/repos-loupedeck/iox-loupedeck"
PROJECT_APNAES="$HOME/repos-apnaes/apnaes-monorepo"
PROJECT_ESLINT="$HOME/repos-apnaes/@finografic-eslint-config"

alias vcc="cd $HOME/verdaccio && l"
alias fino="cd $PROJECTS_MY_NEXT/fino-monorepo && l"
alias iox="cd $PROJECT_IOX_LOUPEDECK && l"
alias apnaes="cd $PROJECT_APNAES && l"
alias admin="cd $PROJECT_APNAES/apps/client && l"

@eslint() {
  cd "$PROJECT_ESLINT" && l
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
  echo "$PROJECT_APNAES"
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
