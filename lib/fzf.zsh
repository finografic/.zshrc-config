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
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --cycle"
# Controls:
# - Window height (40% of terminal)
# - Reverse layout (results appear above prompt)
# - Adds a border around the window

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# Controls default file search:
# - Uses 'fd' instead of 'find' (faster)
# - Shows hidden files
# - Follows symlinks
# - Excludes .git directory

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Uses same settings for CTRL+T file search

export FZF_ALT_C_COMMAND="fd --type d . --hidden"
# Controls directory search with ALT+C:
# - Only shows directories
# - Includes hidden directories
