# OpenLiteSpeed (LSWS) helpers. Only sourced by server-linux.zsh when
# $LSWS_ROOT exists, so none of this is dead weight on a non-LSWS box.

# ============================================================================ #
# NAVIGATION
# ============================================================================ #

alias vh="cd \"$LSWS_ROOT/conf/vhosts/\" && l"
alias lsws="cd \"$LSWS_ROOT\" && l"
alias ws="cd \"$LSWS_ROOT\" && l"
alias example="cd \"$LSWS_ROOT/Example\" && l"
alias api="cd \"$LSWS_ROOT/api\" && l"
alias admin="cd \"$LSWS_ROOT/Example\" && l"

# ============================================================================ #
# RUN COMMANDS AS USER `lsadm`
# ============================================================================ #

# example:
#   sudo -u lsadm which pm2
#   lu which pm2
function lu() {
  sudo -u lsadm "$@"
}

# ============================================================================ #
# LOG FILES
# ============================================================================ #

# logs [std|acc|err] [--clear]
function logs() {
  local log_file="$LSWS_ROOT/logs/stderr.log"

  case "$1" in
  std) log_file="$LSWS_ROOT/logs/stderr.log" ;;
  acc) log_file="$LSWS_ROOT/api/logs/access.log" ;;
  err) log_file="$LSWS_ROOT/logs/error.log" ;;
  esac

  if [[ "$2" == "--clear" ]]; then
    truncate -s 0 "$log_file"
  else
    lnav "$log_file"
  fi
}

# ============================================================================ #
# PM2 (under `lsadm`)
# ============================================================================ #

if command -v pm2 >/dev/null; then
  function _pm2() {
    sudo -u lsadm pm2 "$@"
  }

  function pm2-ls() {
    sudo -u lsadm pm2 ls
  }

  function pm2-logs() {
    sudo -u lsadm pm2 logs
  }

  function pm2-monit() {
    sudo -u lsadm pm2 monit
  }
fi
