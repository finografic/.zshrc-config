# REPOS_REPORTING
alias repos="cd $REPOS_REPORTING && l"
alias skills="cd $HOME/ai-skills && l"
alias sbc="cd $REPOS_SBC && l"
alias repo="cd $REPO_CURRENT && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"
alias pf="cd $HOME/repos-pioneer && l"
alias json="cd $REPOS_PF/$REPOS_PF_JSON_WALKER/ && l"
alias obs="cd $HOME/Documents/OFFICE_VAULT 🔒 && l"

# REPOS REPORTING
alias rui="cd $REPOS_REPORTING/sbc.accounting.reporting.ui/ && l"
alias MASTER="cd $REPOS_REPORTING/MASTER/ && l"

# REPOS INVOICING
alias inv="cd $REPOS_INVOICING/sbc.accounting.invoicing.ui/ && l"
alias inv2="cd $REPOS_INVOICING/INV_PR_GREEN/ && l"
alias biz="cd $REPOS_INVOICING/sbc.core.manage-business.ui/ && l"

# REPOS BANKING
alias bank="cd $REPOS_BANKING/sbc.accounting.banking.ui/ && l"

# REPOS TRADEDOCS + ENTITY
alias docs="cd $REPOS_TRADE/sbc.accounting.tradedocs.ui/ && l"
alias trade="cd $REPOS_TRADE/sbc.accounting.tradeentity.ui/ && l"

# SBC REPOS (miro..)
alias vat="cd $REPOS_SBC/sbc.accountants.vat-centre.ui/ && l"
alias admin="cd $REPOS_SBC/sbc.core.support.ui/ && l"
alias dash="cd $REPOS_SBC/sbc.accounting.dashboard.ui/ && l"
alias poc="cd $REPOS_REPORTING/sbc.accounting.reporting.ui_POCs/ && l"

# SBC REPOS (others..)
alias carbon="cd $REPOS_SBC/carbon/ && l"
alias tokens="cd $REPOS_SBC/design-tokens/ && l"
alias tui="cd $REPOS_SBC/sbc.template.ui/ && l"
alias template="cd $REPOS_SBC/sbc.template.ui/ && l"
alias cop="cd $REPOS_SBC/sbc.common.copilot.ui/ && l"

@root() {
  cd "$REPOS_SBC/sbc.core.root-config.ui" && l
}

alias cm="cd $REPOS_SBC/sbc.accountants.clientmanagement.ui/ && l"
alias notes="cd $REPOS_SBC/sbc.common.notes.ui/ && l"
alias global="cd $REPOS_SBC/sbc.core.globalnav.ui/ && l"
alias org="cd $REPOS_SBC/sbc.core.orghub.ui/ && l"
alias aui="cd $REPOS_SBC/sbc.accounting.ui/ && l"
alias nav="cd $REPOS_SBC/sbc.accounting.ui/ && l"
alias cui="cd $REPOS_SBC/sbc.accounting.compliance.ui/ && l"
alias acc="cd $REPOS_SBC/sbc.accounting.accounts.ui/ && l"
alias dim="cd $REPOS_SBC/sbc.common.dimensions.ui/ && l"

# SERVICE REPOS (others..)
alias api="cd $REPOS_SBC/sbc.reporting.reportengine.service/ && l"

# ============================================================== #
# NEW: GAC

# GAC REPOS (others..)
alias one="cd $REPOS_GAC/carbon-sageone/ && l"
alias gacs="cd $REPOS_GAC && l"
alias soa="cd $REPOS_GAC/sage_one_advanced/ && l"
alias gac="cd $REPOS_GAC/s1_gac_ui/ && l"
alias s1="cd $REPOS_GAC/s1_central_test/ && l"

alias _aws="aws sso login"

# ============================================================== #
# NEW: PIP JOURNAL

alias ai_pip="cd $HOME/AI-PIP && l"
alias pip_log="$HOME/AI-PIP/scripts/pip-log.sh"
alias pip_summary="$HOME/AI-PIP/scripts/pip-weekly-summary.sh"
alias pip_backup="$HOME/AI-PIP/scripts/pip-backup.sh"
alias pip_dir="cd $HOME/AI-PIP"

# ============================================================== #
# NOTE: PERSONAL

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias vcc="cd $HOME/verdaccio && l"
alias dev="echo '${_y}CHOOSE AN ALIAS!${_0}'"
# alias loup="cd $HOME/.local/share/Loupedeck && ls -lAh"
# /Users/REDACTED/Library/Application Support/Logi/LogiPluginService
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'
alias l2="cd $HOME/.local/share && l"

# COMMON ALIASES
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
