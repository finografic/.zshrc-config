# KEYBOARD DEFAULTS
# OVERWRITTEN BY CURRENT ENVIRONMENT
KEYBOARD_LAYOUT="us";
KEYBOARD_LAYOUT_EXT="es";

# SET KEYBOARD LAYOUT
setKeyboardLayout(){
    setxkbmap -layout "$@"
     # NO VARIANT, FOR NOW
}

# DETECT EXTERNAL USB KEYBOARD AND LOAD LAYOUT:
if [[ $(ls -l /dev/input/by-path/*-usb-*-kbd) ]] then
  echo -e "${_c}es_ES${_0} external keyboard: ${_g}available${_0}"; 
  export KEYBOARD_EXTERNAL=1
  # setKeyboardLayout $KEYBOARD_LAYOUT_EXT
else
    echo -e "${_y}External keyboard: ${_g}not available${_0}";
    export KEYBOARD_EXTERNAL=0
  # setKeyboardLayout $KEYBOARD_LAYOUT
fi