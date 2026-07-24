# ============================================================================ #
# FUNCTIONS + ALIASES
# ============================================================================ #

# ZSH CONFIG
export FZF_DEFAULT_COMMAND='fd --type f --ignore-file .ignore'

function config() {
  open -a "/Applications/Visual Studio Code.app" "$ZSHRC_ROOT/.vscode/zshrc-config.code-workspace"
}

# NOTE: .env is loaded in core/env.zsh (canonical, includes SKIP_ENV_LOAD for GitHub Desktop)

# ============================================================================ #
# UTILITIES
# ============================================================================ #

# MISC COM
alias ip="echo '\n\e[37mLocal IP addess: \e[0;35m$IP\n'"

# NEW!! 2024-12-12
function ports() {
  lsof -i -P -n | grep LISTEN | grep -E '127\.0\.0\.1:|[::1]:' | awk '{
    gsub(/\\x20./, " ", $1);
    if ($9 ~ /\[.*\]:/) {
      split($9, addr, "]:");
      addr[1] = addr[1]"]";
    } else {
      split($9, addr, ":");
    }
    printf "\033[95m%-15s %-5s\033[35m %-15s %-5s \033[35m%s:\033[95m%s\033[0m\n", $1, $2, $3, $5, addr[1], addr[2]
  }'
  tput sgr0
}

# ============================================================================ #
# FILE UTILS
# ============================================================================ #

# TAR
function tz() {
  sudo tar -xzf $1 # COMPRESS
  # sudo tar zcvf mongodb-BAK-20181221.tar.gz db
}

function tuz() {
  # DECOMPRESS
  # TODO: USER SELECT FOR *.tar.gz FILES
  echo '\e[32m'
  sudo tar xvpf $1 -C . --checkpoint=.100
  l
}

# FIND: FILE
function f() {
  # OPTION 1.
  # sudo find . -type f -name "$@"
  # OPTION 2. ** BEST OPTION
  # sudo fd "$@"
  # OPTION 3.
  sudo fd --hidden --color 'auto' "$@"
}

# FIND: APT PACKAGES
# sudo ag -i -g "$@" # --depth 5

# FIND: FILE CONTENTS
function contents() {
  # OPTION 1.
  # sudo grep -rnw "." -e "$@"
  sudo grep -rnl "." -e "$@"
}

# FILE/FOLDER PERMISSIONS
function own() {
  sudo chown -R $USER:$USER $1
}
