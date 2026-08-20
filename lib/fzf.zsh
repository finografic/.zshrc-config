# FZF Configuration
((${+_ZSHRC_FZF_LOADED})) && return 0
typeset -g _ZSHRC_FZF_LOADED=1

source "$ZSHRC_ROOT/lib/colors.zsh"

if [[ "$OS_NAME" == "macOS" ]]; then
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi
elif [[ "$OS_NAME" == "Linux" ]]; then
  function install-fzf() {
    if [[ -d "$HOME/.fzf" ]]; then
      print "fzf already installed at ~/.fzf"
      return 0
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && "$HOME/.fzf/install" --bin
    export PATH="$PATH:$HOME/.fzf/bin"
  }
fi

# Optional: Custom FZF settings
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --cycle --style full --ghost 'Type to search…' --color 'gutter:-1,pointer:#e12672,marker:#e17899'"
# Controls:
# - Window height (40% of terminal)
# - Reverse layout (results appear above prompt)
# - Adds a border around the window
# - Cyclic scroll (wraps from bottom back to top)
# - --style full: boxed input/header/footer sections
# - --ghost: placeholder text shown when the query is empty
# - --color: gutter transparent, custom pointer/marker colors

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# Controls default file search:
# - Uses 'fd' instead of 'find' (faster)
# - Shows hidden files
# - Follows symlinks
# - Excludes .git directory

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Uses same settings for CTRL+T file search

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# Enhances CTRL+T (file picker):
# - Skips noisy directories during the walk
# - Shows a syntax-highlighted preview via bat
# - CTRL-/ toggles the preview window position/visibility

export FZF_ALT_C_COMMAND="fd --type d . --hidden"
# Controls directory search with ALT+C:
# - Only shows directories
# - Includes hidden directories

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --tree --color=always {} | head -200'"
# Enhances ALT+C (cd picker):
# - Skips noisy directories during the walk
# - Shows a tree preview of the target directory via eza

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'CTRL-Y to copy command'"
# Enhances CTRL+R (history search):
# - CTRL-Y copies the selected command to the clipboard instead of running it
# - Adds a hint header

export FZF_DEFAULT_OPTS_FILE=""
# (placeholder — leave unset unless you split options into ~/.fzfrc)

# ============================================================================ #
# NOTE: PWD BROWSER
#
# Full-screen split: left list (~33%) of top-level files and dirs in the
# browse dir (not recursive; dirs first, cyan; dot-dirs dim cyan, dot-files
# dim white), right pane (~66%) bat preview.
# Enter on a folder or ".." reloads in-place (no TUI exit). Enter on a file
# prints its path and quits. Esc quits. The shell cds to the last browse dir.
# ============================================================================ #

function b-print-entry() {
  local dir="$1" item="$2"
  local path="$dir/${item%/}"
  if [[ "$item" == '..' ]]; then
    printf '%b%s%b\n' "${_d}${_c}" '..' "${_0}"
  elif [[ -d "$path" ]]; then
    printf '%b%s/%b\n' "${_c}" "${item%/}" "${_0}"
  elif [[ "$item" == .* ]]; then
    printf '%b%s%b\n' "${_grey}" "$item" "${_0}"
  else
    print -r -- "$item"
  fi
}

function b-list-pwd() {
  local dir item
  dir="${${_FZF_B_DIR:-$(<"$_FZF_B_STATE")}:A}"
  [[ -d "$dir" ]] || return 1

  [[ "$dir" != / ]] && b-print-entry "$dir" '..'

  {
    if command -v fd >/dev/null 2>&1; then
      fd --base-directory "$dir" --min-depth 1 --max-depth 1 --type d --hidden --follow --exclude .git --exclude node_modules --exclude target --color never .
      fd --base-directory "$dir" --min-depth 1 --max-depth 1 --type f --hidden --follow --exclude .git --exclude node_modules --exclude target --color never .
    else
      find "$dir" -mindepth 1 -maxdepth 1 ! -name .git ! -name node_modules ! -name target -type d
      find "$dir" -mindepth 1 -maxdepth 1 ! -name .git ! -name node_modules ! -name target ! -type d
    fi
  } | while IFS= read -r item; do
    b-print-entry "$dir" "${item:t}"
  done
}

function b-enter-action() {
  local item="${${1%/}#./}"
  local browse target
  browse="$(<"$_FZF_B_STATE")"
  browse="${browse:A}"

  if [[ -z "$item" ]]; then
    print -r -- ignore
    return
  fi

  if [[ "$item" == '..' ]]; then
    target="${browse:h}"
    [[ -z "$target" ]] && target=/
  else
    target="$browse/$item"
  fi
  target="${target:A}"

  if [[ -d "$target" ]]; then
    print -r -- "$target" >"$_FZF_B_STATE"
    print -r -- "clear-query+reload-sync(zsh --no-rcs -c 'source \"$ZSHRC_ROOT/lib/fzf.zsh\"; b-list-pwd')+first+change-header{$target}"
  else
    print -r -- accept
  fi
}

function b() {
  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "b: fzf is not installed"
    return 1
  fi
  if ! command -v bat >/dev/null 2>&1; then
    print -u2 "b: bat is not installed"
    return 1
  fi

  local state selected browse fzf_status=0
  state="$(mktemp "${TMPDIR:-/tmp}/fzf-b.XXXXXX")" || return 1
  print -r -- "$PWD" >"$state"
  export _FZF_B_STATE="$state"

  selected="$(
    b-list-pwd |
      fzf \
        --ansi \
        --no-sort \
        --height 100% \
        --header "$PWD" \
        --preview 'dir="$(cat "$_FZF_B_STATE")"; if [ {} = .. ]; then t=$(dirname "$dir"); eza --tree --color=always --level 2 "$t" 2>/dev/null || ls -la "$t"; elif [ -d "$dir/"{} ]; then eza --tree --color=always --level 2 "$dir/"{} 2>/dev/null || ls -la "$dir/"{}; else bat -n --color=always -- "$dir/"{}; fi' \
        --preview-window 'right:66%' \
        --bind "enter:transform:source \"$ZSHRC_ROOT/lib/fzf.zsh\" && b-enter-action {}"
  )" || fzf_status=$?

  browse="$(<"$state")"
  rm -f "$state"
  unset _FZF_B_STATE
  cd "$browse"

  ((fzf_status == 0)) || return "$fzf_status"
  [[ -n "$selected" ]] && print -r -- "$browse/${selected%/}"
}
