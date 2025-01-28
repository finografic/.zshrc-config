# PROJECTS_REPORTING
alias repos="cd $PROJECTS_REPORTING && l"
alias sbc="cd $PROJECTS_SBC && l"
alias repo="cd $REPO_CURRENT && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"
alias pf="cd $HOME/repos-pioneer && l"
alias json="cd $PROJECTS_PF/$PROJECTS_PF_JSON_WALKER/ && l"
alias obs="cd $HOME/Documents/OFFICE_VAULT 🔒 && l"

# REPOS REPORTING
alias rui="cd $PROJECTS_REPORTING/sbc.accounting.reporting.ui/ && l"
alias MASTER="cd $PROJECTS_REPORTING/MASTER/ && l"

# REPOS INVOICING
alias inv="cd $PROJECTS_INVOICING/sbc.accounting.invoicing.ui/ && l"

# REPOS TRADEDOCS + ENTITY
alias docs="cd $PROJECTS_TRADE/sbc.accounting.tradedocs.ui/ && l"
alias trade="cd $PROJECTS_TRADE/sbc.accounting.tradeentity.ui/ && l"

# SBC REPOS (miro..)
alias vat="cd $PROJECTS_SBC/sbc.accountants.vat-centre.ui/ && l"
alias admin="cd $PROJECTS_SBC/sbc.core.support.ui/ && l"
alias dash="cd $PROJECTS_SBC/sbc.accounting.dashboard.ui/ && l"
alias poc="cd $PROJECTS_REPORTING/sbc.accounting.reporting.ui_POCs/ && l"

# SBC REPOS (others..)
alias carbon="cd $PROJECTS_SBC/carbon/ && l"
alias tokens="cd $PROJECTS_SBC/design-tokens/ && l"
alias tui="cd $PROJECTS_SBC/sbc.template.ui/ && l"
alias template="cd $PROJECTS_SBC/sbc.template.ui/ && l"
alias cop="cd $PROJECTS_SBC/sbc.common.copilot.ui/ && l"

alias cm="cd $PROJECTS_SBC/sbc.accountants.clientmanagement.ui/ && l"
alias notes="cd $PROJECTS_SBC/sbc.common.notes.ui/ && l"
alias glob="cd $PROJECTS_SBC/sbc.core.globalnav.ui/ && l"
alias org="cd $PROJECTS_SBC/sbc.core.orghub.ui/ && l"
alias aui="cd $PROJECTS_SBC/sbc.accounting.ui/ && l"
alias nav="cd $PROJECTS_SBC/sbc.accounting.ui/ && l"
alias cui="cd $PROJECTS_SBC/sbc.accounting.compliance.ui/ && l"
alias acc="cd $PROJECTS_SBC/sbc.accounting.accounts.ui/ && l"
alias dim="cd $PROJECTS_SBC/sbc.common.dimensions.ui/ && l"

# SERVICE REPOS (others..)
alias api="cd $PROJECTS_SBC/sbc.reporting.reportengine.service/ && l"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias vcc="cd $HOME/verdaccio && l"
alias dev="echo '${_y}CHOOSE AN ALIAS!${_0}'"
# alias loup="cd $HOME/.local/share/Loupedeck && ls -lAh"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'
alias l2="cd $HOME/.local/share && l"

# COMMON ALIASES
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
