# FZF Configuration
((${+_ZSHRC_FZF_LOADED})) && return 0
typeset -g _ZSHRC_FZF_LOADED=1

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
