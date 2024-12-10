#############################################
############ FUNCTIONS + ALIASES ############
#############################################

# ZSH CONFIG
export FZF_DEFAULT_COMMAND='fd --type f --ignore-file .ignore'

function config() {
  open -a "/Applications/Visual Studio Code.app" "$ZSHRC_ROOT/zshrc-config.code-workspace"
}

# REMOVE DUPLICATES FROM PATH - while preserving order
function flatten_PATH() {
  typeset -U PATH
  PATH="${PATH}"
}

function config_V1_FZF() {
  #  TEMP: SAVE CURRENT PATH && CD TO CUSTOM ZSH CONFIG PATH
  PWD_ORIG=$PWD
  cd ${HOME}/.zshrc-config
  # --preview BROKEN !! :()
  # code $(fzf --reverse --preview '[[ $(file --mime {}) =~ binary ]] &&
  #                echo {} is a binary file ||
  #                (rougify {} ||
  #                 lnav {} ||
  #                 cat {}) 2> /dev/null | head -500');
  $EDITOR $(fzf --reverse)
  cd $PWD_ORIG
}

# ENCHANCED CD ("cd-directory")
function cdd() {
  if [ $# -eq 0 ]; then
    cd $(fd --type directory --max-depth 1 | fzf --cycle --reverse) && listing_exa
  else
    cd "$(pwd)/$@"
  fi
}

#####################################
############  UTILITIES  ############
#####################################

# MISC COM
alias ip="echo '\n\e[37mLocal IP addess: \e[0;35m$IP\n'"
alias ports1="echo '\n\e[96m'; sudo grc netstat -ltnp; echo '\e[0m'"
alias ports2="echo '\e[96m'; grc netstat -plnt; echo '\e[0m'"
alias ports3="grc netstat -plnt | grep --invert-match -; echo '\e[0m'"
alias ports4="grc netstat -AaLnW; echo '\e[0m'"

# DYNAMICALLY SET ALIAS, DEPENDING ON ENV
alias ports="lsof -i -P -n | grep LISTEN"
# [ -e /usr/bin/grc ] && alias ports="ports2";

# TO MAKE PORT LIST MORE COMPACT:
# EDIT: sudo vi /usr/share/grc/conf.netstat

# NEW: COMPACT COLUMNS
# regexp=Recv-Q Send-Q
# replace=
# colours=unchanged
# =======
# # NEW: COMPACT COLUMNS
# regexp=     0      0
# replace=
# colours=unchanged
# =======
# # NEW: COMPACT LIST
# regexp=:::
# skip=yes

#####################################
##########  FILE UTILS  #############
#####################################

# TAR
tz() {
  sudo tar -xzf $1 # COMPRESS
  # sudo tar zcvf mongodb-BAK-20181221.tar.gz db
}

tuz() {
  # DECOMPRESS
  # TODO: USER SELECT FOR *.tar.gz FILES
  echo '\e[32m'
  sudo tar xvpf $1 -C . --checkpoint=.100
  l
}

# FIND: FILE
f() {
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
contents() {
  # OPTION 1.
  # sudo grep -rnw "." -e "$@"
  sudo grep -rnl "." -e "$@"
}

# FILE/FOLDER PERMISSIONS
own() {
  sudo chown -R $USER:$USER $1
}

# OWN USING mongodb USER
# mown () {
#   sudo chown -R mongodb:mongodb $1
# }

# IMAGES
function convert-heic() {
  for f in *.heic; do
    echo "Working on file $f"
    heif-convert $f $f.jpg
  done
}

##################################
#############  MISC  #############
##################################

function newsh() {
  NEW_FILE=$1.sh
  echo "#!/bin/zsh" >>$HOME/bin/$NEW_FILE
  chmod +x $HOME/bin/$NEW_FILE
  code $HOME/bin/$NEW_FILE
}

function numberRound() {
  printf "%.0f\n" $1
}

# function numberFloor() {
#   printf ${$(($1))%.*}
# }

msg() {
  # DEFINE + GET MESSAGE TYPE
  declare -A TYPES=(
    [info]=$_c
    [success]=$_g
    [warning]=$_y
    [warn]=$_y
    [danger]=$_r
    [error]=$_r
    [err]=$_r
  )
  _type=${TYPES[$1]}

  # DETERMINE LENGTH OF MESSAGE IN CHARS
  FULL_LENGTH=70
  STRING_LENGTH=$(expr length $2 + 4)

  # SUFFIX (REMAINING CHARACTERS OUT OF 80)
  let SUFFIX_LENGTH=$FULL_LENGTH-$STRING_LENGTH
  SUFFIX_STRING="${_type}"
  for ((i = 1; i <= $SUFFIX_LENGTH; i++)); do
    SUFFIX_STRING+="="
  done

  # FULL MESSAGE OUTPUT
  MSG="\n${_type}== ${_w}${2} ${SUFFIX_STRING}\n"
  echo $MSG

}
