# Depends on the git plugin for work_in_progress()
(( $+functions[work_in_progress] )) || work_in_progress() {}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[cyan]%}]"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"

# Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local branch=$(git_current_branch)
  [[ -n "$branch" ]] || return 0

  # Use the original parse_git_dirty function to determine the status
  local git_status
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    git_status="$(parse_git_dirty)"
  fi

  echo "%{${fg_bold[yellow]}%}$(work_in_progress)%{$reset_color%}\
${ZSH_THEME_GIT_PROMPT_PREFIX}${git_status}${branch}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}
autoload -U colors && colors

#export VCS_PROMPT=hg_prompt_info
export VCS_PROMPT=git_custom_status

base_prompt="%{$fg[cyan]%}[%~% ]%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b "
custom_prompt=""
last_run_time=""
last_vcs_info=""


function pipestatus_parse {
  PIPESTATUS="$pipestatus"
  ERROR=0
  for i in "${(z)PIPESTATUS}"; do
      if [[ "$i" -ne 0 ]]; then
          ERROR=1
      fi
  done

  if [[ "$ERROR" -ne 0 ]]; then
      print "[%{$fg[red]%}$PIPESTATUS%{$fg[cyan]%}]"
  fi
}

# Combine it all into a final right-side prompt
PROMPT='%{$fg[cyan]%}[%~% ]%(?.%{$fg[green]%}.%{$fg[red]%})%B$%b '
function preexec() {
    last_run_time=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')
}

function duration() {
    local duration
    local now=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')
    local last=$1
    local last_split=("${(@s/./)last}")
    local now_split=("${(@s/./)now}")
    local T=$((now_split[1] - last_split[1]))
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    local s=$(((now_split[2] - last_split[2]) / 1000000000.))
    local m=$(((now_split[2] - last_split[2]) / 1000000.))

    (( $D > 0 )) && duration+="${D}d"
    (( $H > 0 )) && duration+="${H}h"
    (( $M > 0 )) && duration+="${M}m"

    if [[ $S -le 0 ]]; then
        printf "%ims" "$m"
    else
        if ! [[ -z $duration ]] && printf "%s" "$duration"
        local sec_milli=$((S + s))
        printf "%.3fs" "$sec_milli"
    fi
}

function precmd() {
    RETVAL=$(pipestatus_parse)
    local info=""

    if [ ! -z "$last_run_time" ]; then
        local elapsed=$(duration $last_run_time)
        last_run_time=$(print $last_run_time | tr -d ".")
        if [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 120 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[magenta]%}"
        elif [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 60 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[red]%}"
        elif [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 10 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[yellow]%}"
        else
            local elapsed_color="%{$fg[green]%}"
        fi
        RPROMPT="${elapsed_color}${elapsed}%{$reset_color%}"
        unset last_run_time
    else
        RPROMPT=""
    fi

    if (( ${+VCS_PROMPT} )); then
        info=$($VCS_PROMPT)
    fi

    [ -z "$info" ] && custom_prompt="$base_prompt" || custom_prompt="$info$base_prompt"
}

function hg_prompt_info() {
    unset output info parts branch_parts branch

    local output=""
    if ! output="$(hg status 2> /dev/null)"; then
        return
    fi

    local info=$(hg log -l1 --template '{author}:{node|short}:{remotenames}:{phabdiff}')
    local parts=(${(@s/:/)info})
    local branch_parts=(${(@s,/,)parts[3]})
    local branch=${branch_parts[-1]}
    [ ! -z "${parts[3]}" ] && [[ "${parts[1]}" =~ "$USER@" ]] && branch=${parts[3]}
    [ -z "${parts[3]}" ] && branch=${parts[2]}

    if [[ ! -z "$output" ]]; then
        local color="%{$fg[red]%}"
    elif [[ "${branch}" == "master" || "${branch}" == "warm" ]]; then
        local color="%{$fg[yellow]%}"
    else
        local color="%{$fg[green]%}"
    fi

    print "%{$fg[cyan]%}[${color}${branch}%{$fg[cyan]%}]"
}

setopt PROMPT_SUBST
PROMPT='$custom_prompt'
