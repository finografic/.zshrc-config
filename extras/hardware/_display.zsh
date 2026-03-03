# DEFAULT DISPLAYS:
# DISPLAY_MAIN="eDP-1-1"
# DISPLAY_EXT="HDMI-1-1"
export BRIGHTNESS=1.4
export DISPLAY_BACKLIGHT_MAX=5273

function get_displays(){

  # MULTI-LINE ARRAY:
  # DISPLAYS=$(xrandr | grep " connected" | awk '{print $1}');

  # SINGLE-LINE ARRAY (EASIER TO WORK WITH):
  export DISPLAYS=$(xrandr | grep " connected" | awk '{print $1}' | tr "\n" " ");

  # SET INDIVIDUAK DISPLAY VARS
  export DISPLAY_MAIN=$(echo $DISPLAYS | awk '{print $1}');
  export DISPLAY_EXT=$(echo $DISPLAYS | awk '{print $2}');

}

# DISPLAY: INTERNAL / LAPTOP
# xrandr --output ${DISPLAY_MAIN} --gamma 1.0:1.0:1.0
# xrandr --output ${DISPLAY_MAIN} --brightness $BRIGHTNESS

# DISPLAY: EXTERNAL / HDMI
# xrandr --output ${DISPLAY_EXT} --gamma 0.9:0.9:0.9
# xrandr --output ${DISPLAY_EXT} --brightness 1.0

# SET BRIGHTNESS: HDMI-1
brightness() {
    BRIGHTNESS=${1:-1}
    xrandr --output ${DISPLAY_MAIN} --brightness $BRIGHTNESS;
}

brightness-x() {
    BRIGHTNESS=${1:-1}
    xrandr --output ${DISPLAY_EXT} --brightness $BRIGHTNESS;
}

function is_hdmi_available() {
    HDMI_AVAILABLE=0;
    HDMI_UNAVAILABLE=`echo $(pactl list sinks | grep "hdmi-output-0*") | grep "not available" | wc -l`;
    if [ $HDMI_UNAVAILABLE = 1 ]; then $HDMI_AVAILABLE=0; else HDMI_AVAILABLE=1; fi
    export HDMI_AVAILABLE;
    if [ $HDMI_AVAILABLE = 1 ]; then
        echo -e "${_c}HDMI${_0} display and audio: ${_g}available${_0}";
    else
        echo "${_c}HDMI${_0} display and audio: ${_r}not available${_0}";
    fi;
}

# SET HDMI_AVAILABLE VAR !!
is_hdmi_available;

function get_dim_display_main() {
  DISPLAY_MAIN_PROPS=$(xrandr | grep "eDP-1-1" | awk '{print $4}'); # 3RD COL USED BY 'primary' FLAG
  DISPLAY_MAIN_PROPS_ARRAY=($(echo $DISPLAY_MAIN_PROPS | tr "x|+" "\n"));
    # GET ABSOLUTE W,H SIZE
  export DISPLAY_MAIN_W=$(echo $DISPLAY_MAIN_PROPS_ARRAY | awk '{print $1}');
  export DISPLAY_MAIN_H=$(echo $DISPLAY_MAIN_PROPS_ARRAY | awk '{print $2}');
  # GET RELATIVE X,Y POS (DUE TO SHARED SCREENS)
  export DISPLAY_MAIN_X=$(echo $DISPLAY_MAIN_PROPS_ARRAY | awk '{print $3}');
  export DISPLAY_MAIN_Y=$(echo $DISPLAY_MAIN_PROPS_ARRAY | awk '{print $4}');
    # SET PADDING
  export MAIN_PAD_LEFT=0;
  export MAIN_PAD_RIGHT=0;
  export MAIN_PAD_TOP=0;
  export MAIN_PAD_BOTTOM=0;
}

function get_dim_hdmi() {
  HDMI_PROPS=$(xrandr | grep "HDMI-1-1" | awk '{print $3}'); # 3RD COL = DIMENSIONS+POS
  HDMI_PROPS_ARRAY=($(echo $HDMI_PROPS | tr "x|+" "\n"));
  # GET ABSOLUTE W,H SIZE
  export HDMI_W=$(echo $HDMI_PROPS_ARRAY | awk '{print $1}');
  export HDMI_H=$(echo $HDMI_PROPS_ARRAY | awk '{print $2}');
  # GET RELATIVE X,Y POS (DUE TO SHARED SCREENS)
  export HDMI_X=$(echo $HDMI_PROPS_ARRAY | awk '{print $3}');
  export HDMI_Y=$(echo $HDMI_PROPS_ARRAY | awk '{print $4}');
  # SET PADDING
  export HDMI_PAD_LEFT=0;
  export HDMI_PAD_RIGHT=170;
  export HDMI_PAD_TOP=40;
  # export HDMI_PAD_BOTTOM=45;
  export HDMI_PAD_BOTTOM=84;
  # GET AVAILABLE W,H SIZE
  export HDMI_AVAIL_W=$((HDMI_W - $HDMI_PAD_RIGHT));
  export HDMI_AVAIL_H=$((HDMI_H - $HDMI_PAD_BOTTOM));

  # HDMI: CALC WIDTH 50%
  HALF_W=$((HDMI_AVAIL_W / 2));
  HALF_H=$((HDMI_AVAIL_H));

  # HDMI: LEFT-50
  LEFT_X=$((DISPLAY_MAIN_W));
  LEFT_Y=$((HDMI_PAD_TOP));
  export HDMI_LEFT_HALF="$LEFT_X,$LEFT_Y,$HALF_W,$HALF_H"

  # HDMI: RIGHT-50
  RIGHT_X=$((DISPLAY_MAIN_W + $HALF_W));
  RIGHT_Y=$((HDMI_PAD_TOP));
  export HDMI_RIGHT_HALF="$RIGHT_X,$RIGHT_Y,$HALF_W,$HALF_H"

   # HDMI: LEFT-33
  LEFT_X=$((DISPLAY_MAIN_W));
  LEFT_Y=$((HDMI_PAD_TOP));
  W_33=$(echo $((HDMI_AVAIL_W*0.33)) | awk '{print int($1)}');
  export HDMI_LEFT_33="$LEFT_X,0,$W_33,$HALF_H"

  # HDMI: RIGHT-66
  RIGHT_X=$((DISPLAY_MAIN_W + $HALF_W));
  RIGHT_Y=$((HDMI_PAD_TOP));
  export HDMI_RIGHT_66="$RIGHT_X,$RIGHT_Y,$HALF_W,$HALF_H"

}

function get_dim_desktop() {

  # DESKTOP DIMENSIONS AVAILABLE
  export DESKTOP_DIMENSIONS=$(wmctrl -d | grep "*" | awk '{print $9}') # RETURNS "W,H"
  export DESKTOP_W=$(echo "${DESKTOP_DIMENSIONS/x/ }" | awk '{print $1}'); # "W"
  export DESKTOP_H=$(echo "${DESKTOP_DIMENSIONS/x/ }" | awk '{print $2}'); # "H"
  # LIST DESKTOPS
  # DIMENSIONS WILL BE SUMS OF *JOINED* MULTIPLE DISPLAYS
  # wmctrl -d
  # 0  * DG: 5120x1800  VP: 0,0  WA: 0,40 4954x1724  [ 0 ]
  # 1  - DG: 5120x1800  VP: 0,0  WA: 0,40 4954x1724  [ 1 ]
  # 2  - DG: 5120x1800  VP: 0,0  WA: 0,40 4954x1724  [ 2 ]
  # "WA" APPEARS TO BE SPACE/POSITION AVAILABLE, TAKING INTO ACCOUNT DOCKED PANELS
}

# ADJUST DISPALYS + THEIR APP WINDOWS
function displays() {

  # if [[ $@ == "hdmi" || $@ == "$DISPLAY_EXT" ]] then
  #   # SET PADDING
  #   PAD_LEFT=$HDMI_PAD_LEFT;
  #   PAD_RIGHT=$HDMI_PAD_RIGHT;
  #   PAD_TOP=$HDMI_PAD_TOP;
  #   PAD_BOTTOM=$HDMI_PAD_BOTTOM;
  # else # DEFAULT DISPALT
  #   # SET PADDING
  #   PAD_LEFT=$MAIN_PAD_LEFT;
  #   PAD_RIGHT=$MAIN_PAD_RIGHT;
  #   PAD_TOP=$MAIN_PAD_TOP;
  #   PAD_BOTTOM=$MAIN_PAD_BOTTOM;
  # fi

  # # HDMI: RIGHT-HALF
  # NEW_W=$((HDMI_W / 2 - $PAD_RIGHT));
  # NEW_H=$((HDMI_H - $POS_OFFSET_Y - $PAD_BOTTOM));
  # NEW_X=$((DISPLAY_MAIN_W + $NEW_W));
  # NEW_Y=$((PAD_TOP));

  # wmctrl -r "All-in-One Messenger" -e 0,$NEW_X,$NEW_Y,$NEW_W,$NEW_H

  # echo "new size:\t w:${_c}$NEW_W${_0}\th:${_c}$NEW_H${_0}";
  # echo "new position:\t x:${_c}$NEW_X${_0}\ty:${_c}$NEW_Y${_0}\n";

  get_dim_hdmi;
  wmctrl -r "Pocket Casts" -e "0,$HDMI_LEFT_HALF"; # NOT WORKING :()
  wmctrl -r "All-in-One Messenger" -e "0,$HDMI_RIGHT_HALF";

}

# RUN BATCH DISPLAY SCRIPTS
get_displays;
get_dim_display_main;
get_dim_hdmi;
# get_dim_total;
displays "hdmi";

