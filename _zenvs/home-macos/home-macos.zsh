# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"
# ============================================================== #

# BUN - https://bun.sh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ============================================================== #

# INCLUDES..
# source "$ZENV_PATH//$ZENV.hardware.zsh";
source "$ZENV_PATH/$ZENV.paths.zsh";
source "$ZENV_PATH/$ZENV.aliases.zsh";
source "$ZENV_PATH/$ZENV.dev.zsh";
source $HOME/.iterm2_shell_integration.zsh

# INCLUDES - if NOT in VSCode environment
[ $TERM_PROGRAM != 'vscode' ] && source "$ZSHRC_ROOT/lib/clean.zsh";
[ $TERM_PROGRAM != 'vscode' ] && source "$ZENV_PATH/$ZENV.backups.zsh";

# ============================================================== #

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";
