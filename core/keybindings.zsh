######################################
#########  KEY BINDINGS  #############
######################################

# Basic history navigation (needs to be before other history bindings)
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history

# Show dots while completing
expand-or-complete-with-dots() {
  print -Pn "%F{red}...%f"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# History substring search configuration (only if the plugin is loaded)
if [[ -n "$commands[history-substring-search-up]" ]]; then
  function up-line-or-history-substring-search-up() {
    if [[ -z $BUFFER ]]; then
      zle up-line-or-history
    else
      zle history-substring-search-up
    fi
  }
  zle -N up-line-or-history-substring-search-up

  function down-line-or-history-substring-search-down() {
    if [[ -z $BUFFER ]]; then
      zle down-line-or-history
    else
      zle history-substring-search-down
    fi
  }
  zle -N down-line-or-history-substring-search-down

  # Arrow key bindings
  bindkey '^[[A' up-line-or-history-substring-search-up
  bindkey '^[[B' down-line-or-history-substring-search-down

  # Terminal mode "application" bindings
  bindkey "$terminfo[kcuu1]" up-line-or-history-substring-search-up
  bindkey "$terminfo[kcud1]" down-line-or-history-substring-search-down
fi

# Make HOME and END keys work
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Alternative key codes (some systems use these)
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# For rxvt
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
