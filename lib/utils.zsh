#############################################
############ FUNCTIONS + ALIASES ############
#############################################

# ZSH CONFIG
export FZF_DEFAULT_COMMAND='fd --type f --ignore-file .ignore'

config() {
  open -a "/Applications/Visual Studio Code.app" "$ZSHRC_ROOT/zshrc-config.code-workspace"
}

# Load environment variables from .env file
_load_env() {
  # Use ZSHRC_ROOT if available, otherwise fall back to script directory
  local ENV_FILE="${ZSHRC_ROOT:-$HOME/.zshrc-config}/.env"

  # Check if .env file exists
  if [[ -f "$ENV_FILE" ]]; then
    # Read each line of the .env file
    while read -r line; do
      # Skip comments and empty lines
      if [[ $line =~ ^\s*# ]] || [[ -z $line ]]; then
        continue
      fi

      # Export the variable to make it available to all sourced files
      export "${line?}"
    done < "$ENV_FILE"
  else
    echo "No .env file found in ${ZSHRC_ROOT:-$HOME/.zshrc-config}/"
    return 1
  fi
}

# Call the function to load the env vars
_load_env

# REMOVE DUPLICATES FROM PATH - while preserving order
flatten_PATH() {
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
cdd() {
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

# NEW!! 2024-12-12
ports() {
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
convert-heic() {
  for f in *.heic; do
    echo "Working on file $f"
    heif-convert $f $f.jpg
  done
}

##################################
#############  MISC  #############
##################################

newsh() {
  NEW_FILE=$1.sh
  echo "#!/bin/zsh" >>$HOME/bin/$NEW_FILE
  chmod +x $HOME/bin/$NEW_FILE
  code $HOME/bin/$NEW_FILE
}

numberRound() {
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


