# FZF Configuration
if [ "$OS_NAME" = "macOS" ]; then
  # Add Homebrew FZF to path if not present
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi
elif [ "$OS_NAME" = "Linux" ]; then
  # Auto-install FZF if missing
  [ ! -d "$HOME/.fzf" ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
fi

# Optional: Custom FZF settings
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
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
