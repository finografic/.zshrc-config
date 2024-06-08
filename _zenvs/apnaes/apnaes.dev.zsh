# PROJECTS
PROJECTS="/home/apnaes/repos"

alias repos="cd $PROJECTS && l"
alias web="cd $PROJECTS/apnaes-web && l"
alias admin="cd $PROJECTS/apnaes-web && l"
alias api="cd $PROJECTS/apnaes-api && l"

group_no() {
  if [[ $1 = "-R" && $2 > "" ]] then
     sudo chown -R nobody:nogroup $2
  elif [[ $1 > "" ]] then
    sudo chown nobody:nogroup $1
  else
    echo "invalid arguments"
  fi
}

group_ls() {
  if [[ $1 = "-R" && $2 > "" ]] then
     sudo chown -R lsadm:apnaes $2
  elif [[ $1 > "" ]] then
    sudo chown lsadm:apnaes $1
  else
    echo "invalid arguments"
  fi
}
