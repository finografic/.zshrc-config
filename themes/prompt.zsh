# Git prompt styling
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}["
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"

# Execution time configuration (with unique function names)
function _exec_time_preexec() {
  timer=$(($(print -P %D{%s%6.}) / 1000))
}

function _exec_time_precmd() {
  if [ $timer ]; then
    now=$(($(print -P %D{%s%6.}) / 1000))
    elapsed=$(($now - $timer))
    RPROMPT="%F{240}${elapsed}ms%{$reset_color%}"
    unset timer
  else
    RPROMPT=""
  fi
}

# Register only execution time hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec _exec_time_preexec
add-zsh-hook precmd _exec_time_precmd
