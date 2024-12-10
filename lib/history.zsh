# Clear any existing history in memory
fc -p # Reset history parameters
fc -P # Clear history stack

# Clear any existing history file settings
unset HISTFILE
unset HISTSIZE
unset SAVEHIST

# Set our history parameters
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=2000

# Disable sharing between sessions initially
setopt NO_SHARE_HISTORY
unsetopt SHARE_HISTORY

# Other history options
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# Extended options
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY

# Force history to be loaded correctly at startup
fc -R "$HISTFILE"

HISTORY_IGNORE='(node -e*vscode-sqltools*|ls|pwd|exit)'
HIST_STAMPS="dd/mm/yyyy"
