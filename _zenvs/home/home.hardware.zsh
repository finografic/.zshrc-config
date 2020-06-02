# KEYBOARDS: LAYOUTS + INPUTS

export LC_ALL=es_ES.UTF-8
export LANGUAGE=en_US.UTF-8

# BEFORE CHANGE:
#xkb_keymap {
  #xkb_keycodes  { include "evdev+aliases(qwerty)" };
  #xkb_types     { include "complete"      };
  #xkb_compat    { include "complete"      };
  #xkb_symbols   { include "pc+es(winkeys)+eu:2+inet(evdev)"       };
  #xkb_geometry  { include "pc(pc104)"     };
#};

# xkb_keymap {
# xkb_keycodes  { include "evdev+aliases(qwerty)" };
# xkb_types     { include "complete"      };
# xkb_compat    { include "complete"      };
# xkb_symbols   { include "pc+es(winkeys)+inet(evdev)"    };
# xkb_geometry  { include "pc(pc104)"     };
# };

# DEFAULT KEYBOARD LAYOUTS + VAIRANTS
KEYBOARD_LAYOUT="us";
KEYBOARD_LAYOUT_EXT="es";

# SET KEYBOARD LAYOUT
setKeyboardLayout $KEYBOARD_LAYOUT_EXT;

# DISPLAYS
DISPLAY_MAIN="eDP-1-1"
DISPLAY_EXT="HDMI-1-1"
export BRIGHTNESS=1.4

# MOUNT EXTERNAL DRIVES
# PATH_ORIG=$(pwd)
# cd /media/justin/HD1TB_p1/ 2> /dev/null
# cd /media/justin/HD1TB_p2/ 2> /dev/null
# cd /media/justin/WALKMAN/MUSIC/ 2> /dev/null
# cd $PATH_ORIG 2> /dev/null
