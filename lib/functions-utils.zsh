#############################################
############ FUNCTIONS + ALIASES ############
#############################################

# ZSH CONFIG
export FZF_DEFAULT_COMMAND='fd --type f --ignore-file .ignore'

function config() {
  # MUCH EASIER & MORE CONCISE !!
  atom ${HOME}/.zshrc-config;
}


function config_V1_FZF() {
  #  TEMP: SAVE CURRENT PATH && CD TO CUSTOM ZSH CONFIG PATH
  PWD_ORIG=$PWD ;
  cd ${HOME}/.zshrc-config;
  # --preview BROKEN !! :()
  # code $(fzf --reverse --preview '[[ $(file --mime {}) =~ binary ]] &&
  #                echo {} is a binary file ||
  #                (rougify {} ||
  #                 lnav {} ||
  #                 cat {}) 2> /dev/null | head -500');
  $EDITOR $(fzf --reverse);
  cd $PWD_ORIG;
}

# ENCHANCED CD ("cd-directory")
function cdd() {
  if [ $# -eq 0 ]; then
    cd $(fd --type directory --max-depth 1 | fzf --cycle --reverse) && listing_exa
  else
    cd "$(pwd)/$@";
  fi
}

# TERMINAL MESSAGE: function msg(type, "string")
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
  for ((i=1;i<=$SUFFIX_LENGTH;i++));
  do
    SUFFIX_STRING+="="
  done

  # FULL MESSAGE OUTPUT
  MSG="\n${_type}== ${_w}${2} ${SUFFIX_STRING}\n"
  echo $MSG;

}

#####################################
############  UTILITIES  ############
#####################################

# MISC COM
alias ip="echo '\n\e[37mLocal IP addess: \e[0;35m$IP\n'"
alias ports1="echo '\n\e[96m'; sudo grc netstat -ltnp; echo '\e[0m'";
alias ports2="echo '\e[96m'; grc netstat -plnt; echo '\e[0m'";
alias ports3="grc netstat -plnt | grep --invert-match -; echo '\e[0m'";
alias ports4="grc netstat -AaLnW; echo '\e[0m'";

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

##################################
#########  DISKSPACE  ############
##################################

function diskspace_df_brief(){
  echo "\n";
  # LIST IMPORTANT DRIVES, IGNORE TMPS AND SNAPS etc..
  # df -h;
  df -h -x "squashfs" -x "devtmpfs"
}

function diskspace_df_with_temps(){
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m";
  df -H -ai | sed -n '1!p'
}

function diskspace_df_mac(){
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -b -H -ailn | grep "" --max-count 1)\e[0m";
  df -b -H -ailn | sed -n '1!p'
}

function diskspace_df_android(){
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m";
  df -H -ai | sed -n '1!p'
}

# DISK SPACE
function diskspace_ncdu(){
  ncdu;
}

function diskspace_pydf(){ # PYTHON & SNAP REQUIRED !!
  # NEW !!!  PYDF - NOW COLOR-CODED :D
  # 0: RESET
  # 1: Bold/Bright
  # 2: Dim
  # 4: Underlined
  # 5: Blink
  GREP_WHITE="ms=01;37"
  GREP_GREEN="ms=01;32"
  GREP_BLUE="ms=01;34"
  GREP_CYAN="ms=01;36"
  GREP_YELLOW="ms=01;33"
  GREP_RED="ms=01;31"

  echo "\n";

  # PYDF HEADER
  export GREP_COLORS=$GREP_BLUE;
  pydf -h | grep "snap" -v --max-count 1 | grep "Filesystem\|Size\|Used\|Avail\|Use%\|Mounted on"

  # SET VARIABLES
  METER_MAX=$(pydf -h | grep "snap" -v | expr length "\[(.*?)\]" - 2);
  # METER_VALUE=$(pydf -h | grep 'snap' -v | grep '/ ' | grep -o '#' | wc -l);
  #METER_VALUE=$(pydf -h | grep 'snap' -v | grep '/ ' | grep -o '#' | wc -l);
  # PYDF_RESULT=$(pydf -h | grep 'snap' -v | grep '/');

  # ======================================================

  # repl() {
  #   if (( $2 > 0 )) printf $1%.s $(eval "echo {1..$(($2))}");
  #   # printf $1%.s $(eval "echo {1..$(($2))}");
  # }

  # array=();
  # meter_empty="[$(repl '.' $METER_MAX)]";

  # for i in {1..$METER_MAX}; do
  #   value_string=$(repl '#' $i);
  #   free_string=$(repl '.' $(($METER_MAX - $i)));
  #   meter_string="[$value_string$free_string]";
  #   echo "$i : $meter_string";
  #   array+=($meter_string)
  # done

  VAL_EMPTY=0
  VAL_FULL=$METER_MAX;

  VAL_LO_MIN=$(( $VAL_EMPTY + 1)) ;
  VAL_LO_MAX=$(numberRound $(( 0.6 * $METER_MAX )) );
  VAL_HI_MIN=$(( $VAL_LO_MAX + 1)) ;
  VAL_HI_MAX=$(numberFloor $(( 0.9 * $METER_MAX )) );

  FREE_LO_MIN=$(( $METER_MAX - $VAL_LO_MAX ));
  FREE_LO_MAX=$(( $METER_MAX - $VAL_LO_MIN ));
  FREE_HI_MIN=$(( $METER_MAX - $VAL_HI_MAX ));
  FREE_HI_MAX=$(( $METER_MAX - $VAL_HI_MIN ));

  # EMPTY: 0%
  export GREP_COLORS=$GREP_BLUE;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{0\}[.]\{$METER_MAX\}\]"

  # LO: 1-60%
  export GREP_COLORS=$GREP_GREEN;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_LO_MIN,$VAL_LO_MAX\}[.]\{$FREE_LO_MIN,$FREE_LO_MAX\}\]"

  # HI: 60-90%
  export GREP_COLORS=$GREP_YELLOW;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_HI_MIN,$VAL_HI_MAX\}[.]\{$FREE_HI_MIN,$FREE_HI_MAX\}\]"

  # FULL: 90% +
  export GREP_COLORS=$GREP_RED;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$METER_MAX\}[.]\{0\}\]"

}

# DEFINE DEFAULT "space" METHOD:
if [ $OS_NAME = 'Linux' ]; then alias space=diskspace_df_brief;
  elif [ $OS_NAME = 'macOS' ]; then  alias space=diskspace_df_mac;
  elif [ $OS_NAME = 'Android' ]; then alias space=diskspace_df_android;
else alias space=diskspace_df_android; # DEFAULT ALIAS
fi;


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
function convert-heic(){
  for f in *.heic; do
    echo "Working on file $f"
    heif-convert $f $f.jpg
  done;
}

##################################
#########  DISKSPACE  ############
##################################

function diskspace_df_brief(){
  echo "\n";
  # LIST IMPORTANT DRIVES, IGNORE TMPS AND SNAPS etc..
  # df -h;
  df -h -x "squashfs" -x "devtmpfs"
}

function diskspace_df_with_temps(){
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m";
  df -H -ai | sed -n '1!p'
}

function diskspace_df_mac(){
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -b -H -ailn | grep "" --max-count 1)\e[0m";
  df -b -H -ailn | grep "/Volumes/.timemachine" -v | grep "/Volumes/.com.apple.*" -v | sed -n '1!p'
}

function diskspace_df_android(){
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m";
  df -H -ai | sed -n '1!p'
}

# DISK SPACE
function diskspace_ncdu(){
  ncdu;
}

function diskspace_pydf(){ # PYTHON & SNAP REQUIRED !!
  # NEW !!!  PYDF - NOW COLOR-CODED :D
  # 0: RESET
  # 1: Bold/Bright
  # 2: Dim
  # 4: Underlined
  # 5: Blink
  GREP_WHITE="ms=01;37"
  GREP_GREEN="ms=01;32"
  GREP_BLUE="ms=01;34"
  GREP_CYAN="ms=01;36"
  GREP_YELLOW="ms=01;33"
  GREP_RED="ms=01;31"

  echo "\n";

  # PYDF HEADER
  export GREP_COLORS=$GREP_BLUE;
  pydf -h | grep "snap" -v --max-count 1 | grep "Filesystem\|Size\|Used\|Avail\|Use%\|Mounted on"

  # SET VARIABLES
  METER_MAX=$(pydf -h | grep "snap" -v | expr length "\[(.*?)\]" - 2);
  # METER_VALUE=$(pydf -h | grep 'snap' -v | grep '/ ' | grep -o '#' | wc -l);
  #METER_VALUE=$(pydf -h | grep 'snap' -v | grep '/ ' | grep -o '#' | wc -l);
  # PYDF_RESULT=$(pydf -h | grep 'snap' -v | grep '/');

  # ======================================================

  # repl() {
  #   if (( $2 > 0 )) printf $1%.s $(eval "echo {1..$(($2))}");
  #   # printf $1%.s $(eval "echo {1..$(($2))}");
  # }

  # array=();
  # meter_empty="[$(repl '.' $METER_MAX)]";

  # for i in {1..$METER_MAX}; do
  #   value_string=$(repl '#' $i);
  #   free_string=$(repl '.' $(($METER_MAX - $i)));
  #   meter_string="[$value_string$free_string]";
  #   echo "$i : $meter_string";
  #   array+=($meter_string)
  # done

  VAL_EMPTY=0
  VAL_FULL=$METER_MAX;

  VAL_LO_MIN=$(( $VAL_EMPTY + 1)) ;
  VAL_LO_MAX=$(numberRound $(( 0.6 * $METER_MAX )) );
  VAL_HI_MIN=$(( $VAL_LO_MAX + 1)) ;
  VAL_HI_MAX=$(numberFloor $(( 0.9 * $METER_MAX )) );

  FREE_LO_MIN=$(( $METER_MAX - $VAL_LO_MAX ));
  FREE_LO_MAX=$(( $METER_MAX - $VAL_LO_MIN ));
  FREE_HI_MIN=$(( $METER_MAX - $VAL_HI_MAX ));
  FREE_HI_MAX=$(( $METER_MAX - $VAL_HI_MIN ));

  # EMPTY: 0%
  export GREP_COLORS=$GREP_BLUE;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{0\}[.]\{$METER_MAX\}\]"

  # LO: 1-60%
  export GREP_COLORS=$GREP_GREEN;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_LO_MIN,$VAL_LO_MAX\}[.]\{$FREE_LO_MIN,$FREE_LO_MAX\}\]"

  # HI: 60-90%
  export GREP_COLORS=$GREP_YELLOW;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_HI_MIN,$VAL_HI_MAX\}[.]\{$FREE_HI_MIN,$FREE_HI_MAX\}\]"

  # FULL: 90% +
  export GREP_COLORS=$GREP_RED;
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$METER_MAX\}[.]\{0\}\]"

}

# DEFINE DEFAULT "space" METHOD:
if [ $OS_NAME = 'Linux' ]; then alias space=diskspace_df_brief;
  elif [ $OS_NAME = 'macOS' ]; then  alias space=diskspace_df_mac;
  elif [ $OS_NAME = 'Android' ]; then alias space=diskspace_df_android;
else alias space=diskspace_df_android; # DEFAULT ALIAS
fi;


##################################
#############  MISC  #############
##################################

function newsh() {
  NEW_FILE=$1.sh
  echo "#!/bin/bash" >> $HOME/bin/$NEW_FILE
  chmod +x $HOME/bin/$NEW_FILE
  code $HOME/bin/$NEW_FILE
}

function numberRound() {
  printf "%.0f\n" $1
}

function numberFloor() {
  printf ${$(($1))%.*}
}
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
  for ((i=1;i<=$SUFFIX_LENGTH;i++));
  do
    SUFFIX_STRING+="="
  done

  # FULL MESSAGE OUTPUT
  MSG="\n${_type}== ${_w}${2} ${SUFFIX_STRING}\n"
  echo $MSG;

}
