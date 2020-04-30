# DEFAULT DISPLAYS:
DISP_INT="eDP-1-1"
DISP_EXT="HDMI-1-1"
export BRIGHTNESS=1.4

# BACKLIGHT - MAX BRIGHTNESS
export DISPLAY_BACKLIGHT_MAX=5273

# DISPLAY: INTERNAL / LAPTOP
# xrandr --output ${DISP_INT} --gamma 1.0:1.0:1.0
# xrandr --output ${DISP_INT} --brightness $BRIGHTNESS

# DISPLAY: EXTERNAL / HDMI
# xrandr --output ${DISP_EXT} --gamma 0.9:0.9:0.9
# xrandr --output ${DISP_EXT} --brightness 1.0

# SET BRIGHTNESS: HDMI-1
bright() {
    BRIGHTNESS=${1:-1}
    xrandr --output ${DISP_INT} --brightness $BRIGHTNESS;
}

brightx() {
    BRIGHTNESS=${1:-1}
    xrandr --output ${DISP_EXT} --brightness $BRIGHTNESS;
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
