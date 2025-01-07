# UNIVERSAL ALIASES
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

alias api="cd $HOME/repos-apnaes/apnaes-api && l"
alias web="cd $HOME/repos-apnaes/apnaes-web && l"
alias admin="cd $HOME/repos-apnaes/apnaes-web && l"
alias vite="cd $HOME/repos-apnaes/apnaes-web--VITE && l"
alias json="cd $PROJECTS/repos-dev-next-my/json-walker && l"

alias driz="cd $HOME/repos-db-api-services/__DRIZZLE__/api-fastify-drizzle && l"
# alias loup="cd $HOME/.local/share/Loupedeck && ls -lAh"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'

# NEW - LOUPE DX
# PROJECT_LOUPEDX="$HOME/repos/repos-dev-react/loupedx"
PROJECTS_MY_NEXT="$HOME/repos-my-next"
alias hnx="cd $PROJECTS_MY_NEXT/hnx-monorepo && l"

PROJECT_IOX_LOUPEDECK="$PROJECTS_MY_NEXT/iox-loupedeck"
alias iox="cd $PROJECT_IOX_LOUPEDECK && l"
alias @config="cd $PROJECT_IOX_LOUPEDECK/config && l"
alias @server="cd $PROJECT_IOX_LOUPEDECK/apps/server && l"
alias @client="cd $PROJECT_IOX_LOUPEDECK/apps/client && l"
alias @globals="cd $PROJECT_IOX_LOUPEDECK/packages/globals && l"
alias @eslint="cd $PROJECT_IOX_LOUPEDECK/packages/eslint-config && l"
alias @i18n="cd $PROJECT_IOX_LOUPEDECK/packages/i18n && l"
alias @shared="cd $PROJECT_IOX_LOUPEDECK/packages/shared && l"

alias vt="cd /Users/REDACTED/repos-apnaes/apnaes-vite-chat && l"

# COMMON ALIASES
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
