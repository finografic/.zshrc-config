# ============================================================================ #
# NOTE: PROMPT - Powerlevel10k theme loading
# ============================================================================ #

# NOTE: POWERLEVEL9K_INSTANT_PROMPT=quiet is set in ~/.zshrc BEFORE instant prompt
# It must be set before the instant prompt file is sourced to take effect

# Load powerlevel10k theme (installed via antidote plugins)
# The theme itself is loaded by antidote, this just loads the user config

# Load user p10k configuration (system-specific customizations)
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
