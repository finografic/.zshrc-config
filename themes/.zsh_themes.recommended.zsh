# DEFAULT Theme
ohmyzsh/ohmyzsh path:themes/gallois.zsh-theme

# ============================================================= #

# CHANGE BASIC THEMES:
# Replace gallois in your config with any of these:

gallois - MY PICK
refined - clean, git-focused
jonathan - minimal but informative
lambda - super minimal
eastwood - clean with nice colors
clean - as the name suggests
minimal - extremely minimal
pure - elegant simplicity

# PREMIUM THEMES
# Add these instead of oh-my-zsh themes:

# Then in plugins file:
starship/starship kind:fpath

# Powerlevel10k (highly customizable)
romkatv/powerlevel10k

# ============================================================= #

# SWITCHING THEMES

1. Manual: Edit .zsh_plugins.zsh and regenerate
Preview: Use antidote bundle "ohmyzsh/ohmyzsh path:themes/THEME_NAME.zsh-theme" to test temporarily

# RESOURCES
Oh-My-Zsh Themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
Awesome Zsh Plugins: https://github.com/unixorn/awesome-zsh-plugins
r/zsh Subreddit: https://www.reddit.com/r/zsh/

# QUICK THEME SWITCH SCRIPT

$()$(
  sh
  # Add to your .zshrc
  switch_theme() {
    sed -i '' "s|path:themes/.*\.zsh-theme|path:themes/$1.zsh-theme|" ~/.zshrc-config/.zsh_plugins.zsh
    source ~/.zshrc
  }
  # Usage: switch_theme refined
)$()
