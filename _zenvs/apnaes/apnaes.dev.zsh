# REPOS
REPOS="/home/apnaes/repos"

alias repos="cd $REPOS && l"
# alias web="cd $REPOS/apnaes-web && l"
# alias admin="cd $REPOS/apnaes-web && l"
# alias api="cd $REPOS/apnaes-api && l"

# ============================================================================ #
# TODO: RUN COMMANDS AS USER `lsadm`..
# ============================================================================ #

# example:
# $ sudo -u lsadm which pm2
# $ lu which pm2

function lu() {
  sudo -u lsadm "$@"
}

# ============================================================================ #
# PERMISSIONS..
# ============================================================================ #

function chown-no() {
  if [[ $1 = "-R" && $2 > "" ]]; then
    sudo chown -R nobody:nogroup $2
  elif [[ $1 > "" ]]; then
    sudo chown nobody:nogroup $1
  else
    echo "invalid arguments"
  fi
}

function chown-ls() {
  if [[ $1 = "-R" && $2 > "" ]]; then
    sudo chown -R lsadm:nogroup $2
  elif [[ $1 > "" ]]; then
    sudo chown lsadm:nogroup $1
  else
    echo "invalid arguments"
  fi
}

function chown-apnaes() {
  if [[ $1 = "-R" && $2 > "" ]]; then
    sudo chown -R lsadm:apnaes $2
  elif [[ $1 > "" ]]; then
    sudo chown lsadm:apnaes $1
  else
    echo "invalid arguments"
  fi
}

# ============================================================================ #
# LOG FILES..
# ============================================================================ #

function logs() {
  # DEFAULT LOG FILE
  LOG_FILE="/usr/local/lsws/logs/stderr.log"

  # SET LOG FILE
  [[ $1 = 'std' ]] && LOG_FILE="/usr/local/lsws/logs/stderr.log"
  [[ $1 = 'acc' ]] && LOG_FILE="/usr/local/lsws/api/logs/access.log"
  [[ $1 = 'err' ]] && LOG_FILE="/usr/local/lsws/logs/error.log"

  if [[ $2 > "" && $2 = '--clear' ]]; then
    # CLEAR LOG (COMPLETELY), LEAVE PERMISSIONS etc..
    truncate -s 0 $LOG_FILE
  else
    # OPEN + VIEW LOG..
    lnav $LOG_FILE
  fi
}

# ============================================================================ #
# PM2 OPERATIONS - USER `lsadm`..
# ============================================================================ #

# $ sudo -u lsadm pm2 monit
# $ sudo -u lsadm pm2 logs

function _pm2() {
  # WILDCARD PM2 COMMANDS
  sudo -u lsadm pm2 "$@"
}

function pm2-ls() {
  # LIST PM2 INSTANCES
  sudo -u lsadm pm2 ls
}

function pm2-logs() {
  # CAT (and follow??) last 15 lines of RUNNING PM2 instance
  # actual log file: /.pm2/logs/API-out-0.log
  sudo -u lsadm pm2 logs
}

function pm2-monit() {
  # PM2 MONITOR
  sudo -u lsadm pm2 monit
}

# ============================================================================ #
