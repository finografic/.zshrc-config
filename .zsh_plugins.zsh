# Required libraries
ohmyzsh/ohmyzsh path:lib/git.zsh

# Theme
# ohmyzsh/ohmyzsh path:themes/gallois.zsh-theme
# starship/starship kind:fpathk
romkatv/powerlevel10k

# Core plugins and completions (load first)
zsh-users/zsh-completions
ohmyzsh/ohmyzsh path:plugins/brew
ohmyzsh/ohmyzsh path:plugins/grc

# Git and development tools
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/git-extras
ohmyzsh/ohmyzsh path:plugins/rsync
ohmyzsh/ohmyzsh path:plugins/sudo

# FZF setup
junegunn/fzf kind:clone
junegunn/fzf path:shell
Aloxaf/fzf-tab
unixorn/fzf-zsh-plugin

# Node/Development tools
lukechilds/zsh-nvm
ohmyzsh/ohmyzsh path:plugins/yarn

# Directory enhancement
supercrabtree/k

# These must be last (order matters)
zsh-users/zsh-history-substring-search
zsh-users/zsh-syntax-highlighting
