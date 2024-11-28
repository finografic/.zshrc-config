##################################
#########  DISKSPACE  ############
##################################

function diskspace_df_brief() {
  echo "\n"
  # LIST IMPORTANT DRIVES, IGNORE TMPS AND SNAPS etc..
  # df -h;
  df -h -x "squashfs" -x "devtmpfs"
}

function diskspace_df_with_temps() {
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
  df -H -ai | sed -n '1!p'
}

function diskspace_df_mac() {
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -b -H -ailn | grep "" --max-count 1)\e[0m"
  df -b -H -ailn | sed -n '1!p'
}

function diskspace_df_android() {
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
  df -H -ai | sed -n '1!p'
}

# DISK SPACE
function diskspace_ncdu() {
  ncdu
}

function diskspace_pydf() { # PYTHON & SNAP REQUIRED !!
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

  echo "\n"

  # PYDF HEADER
  export GREP_COLORS=$GREP_BLUE
  pydf -h | grep "snap" -v --max-count 1 | grep "Filesystem\|Size\|Used\|Avail\|Use%\|Mounted on"

  # SET VARIABLES
  METER_MAX=$(pydf -h | grep "snap" -v | expr length "\[(.*?)\]" - 2)
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
  VAL_FULL=$METER_MAX

  VAL_LO_MIN=$(($VAL_EMPTY + 1))
  VAL_LO_MAX=$(numberRound $((0.6 * $METER_MAX)))
  VAL_HI_MIN=$(($VAL_LO_MAX + 1))
  VAL_HI_MAX=$(numberFloor $((0.9 * $METER_MAX)))

  FREE_LO_MIN=$(($METER_MAX - $VAL_LO_MAX))
  FREE_LO_MAX=$(($METER_MAX - $VAL_LO_MIN))
  FREE_HI_MIN=$(($METER_MAX - $VAL_HI_MAX))
  FREE_HI_MAX=$(($METER_MAX - $VAL_HI_MIN))

  # EMPTY: 0%
  export GREP_COLORS=$GREP_BLUE
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{0\}[.]\{$METER_MAX\}\]"

  # LO: 1-60%
  export GREP_COLORS=$GREP_GREEN
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_LO_MIN,$VAL_LO_MAX\}[.]\{$FREE_LO_MIN,$FREE_LO_MAX\}\]"

  # HI: 60-90%
  export GREP_COLORS=$GREP_YELLOW
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_HI_MIN,$VAL_HI_MAX\}[.]\{$FREE_HI_MIN,$FREE_HI_MAX\}\]"

  # FULL: 90% +
  export GREP_COLORS=$GREP_RED
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$METER_MAX\}[.]\{0\}\]"

}

# DEFINE DEFAULT "space" METHOD:
if [ $OS_NAME = 'Linux' ]; then
  alias space=diskspace_df_brief
elif [ $OS_NAME = 'macOS' ]; then
  alias space=diskspace_df_mac
elif [ $OS_NAME = 'Android' ]; then
  alias space=diskspace_df_android
else
  alias space=diskspace_df_android # DEFAULT ALIAS
fi

##################################
#########  DISKSPACE  ############
##################################

function diskspace_df_brief() {
  echo "\n"
  # LIST IMPORTANT DRIVES, IGNORE TMPS AND SNAPS etc..
  # df -h;
  df -h -x "squashfs" -x "devtmpfs"
}

function diskspace_df_with_temps() {
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
  df -H -ai | sed -n '1!p'
}

function diskspace_df_mac() {
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -b -H -ailn | grep "" --max-count 1)\e[0m"
  df -b -H -ailn | grep "/Volumes/.timemachine" -v | grep "/Volumes/.com.apple.*" -v | sed -n '1!p'
}

function diskspace_df_android() {
  # LIST IMPORTANT DRIVES ONLY
  # HEADERS (CYAN)
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
  df -H -ai | sed -n '1!p'
}

# DISK SPACE
function diskspace_ncdu() {
  ncdu
}

function diskspace_pydf() { # PYTHON & SNAP REQUIRED !!
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

  echo "\n"

  # PYDF HEADER
  export GREP_COLORS=$GREP_BLUE
  pydf -h | grep "snap" -v --max-count 1 | grep "Filesystem\|Size\|Used\|Avail\|Use%\|Mounted on"

  # SET VARIABLES
  METER_MAX=$(pydf -h | grep "snap" -v | expr length "\[(.*?)\]" - 2)
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
  VAL_FULL=$METER_MAX

  VAL_LO_MIN=$(($VAL_EMPTY + 1))
  VAL_LO_MAX=$(numberRound $((0.6 * $METER_MAX)))
  VAL_HI_MIN=$(($VAL_LO_MAX + 1))
  VAL_HI_MAX=$(numberFloor $((0.9 * $METER_MAX)))

  FREE_LO_MIN=$(($METER_MAX - $VAL_LO_MAX))
  FREE_LO_MAX=$(($METER_MAX - $VAL_LO_MIN))
  FREE_HI_MIN=$(($METER_MAX - $VAL_HI_MAX))
  FREE_HI_MAX=$(($METER_MAX - $VAL_HI_MIN))

  # EMPTY: 0%
  export GREP_COLORS=$GREP_BLUE
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{0\}[.]\{$METER_MAX\}\]"

  # LO: 1-60%
  export GREP_COLORS=$GREP_GREEN
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_LO_MIN,$VAL_LO_MAX\}[.]\{$FREE_LO_MIN,$FREE_LO_MAX\}\]"

  # HI: 60-90%
  export GREP_COLORS=$GREP_YELLOW
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$VAL_HI_MIN,$VAL_HI_MAX\}[.]\{$FREE_HI_MIN,$FREE_HI_MAX\}\]"

  # FULL: 90% +
  export GREP_COLORS=$GREP_RED
  pydf -h | grep "/" | grep "/snap" -v | grep "\[[#]\{$METER_MAX\}[.]\{0\}\]"

}

# DEFINE DEFAULT "space" METHOD:
if [ $OS_NAME = 'Linux' ]; then
  alias space=diskspace_df_brief
elif [ $OS_NAME = 'macOS' ]; then
  alias space=diskspace_df_mac
elif [ $OS_NAME = 'Android' ]; then
  alias space=diskspace_df_android
else
  alias space=diskspace_df_android # DEFAULT ALIAS
fi
