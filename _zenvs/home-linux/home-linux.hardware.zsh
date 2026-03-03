# CORE HARDWARE CONNECTIONS
source "$ZSHRC_ROOT/extras/hardware/_keyboard.zsh";
source "$ZSHRC_ROOT/extras/hardware/_display.zsh";
source "$ZSHRC_ROOT/extras/hardware/_audio.zsh";
echo ""; # NEWLINE SPACE

# KEYBOARDS: LAYOUTS + INPUTS

# export LC_ALL=es_ES.UTF-8
export LC_ALL=en_US.UTF-8 # TEST THIS... ABOVE es_ES IS AFFECTING CLI LANGUAGE
export LANGUAGE=en_US.UTF-8

# TESTING COMMAND "locales"...
# STILL GETTING ALL en_US.UTF-8 :(
export EN="en_US.UTF-8"
export EU="en_IE.UTF-8"
export ES="es_ES.UTF-8"
export LANG=$EN
export LANGUAGE=$EN
export LC_CTYPE=$EN
export LC_NUMERIC=$EU
export LC_TIME=$EU
export LC_COLLATE=$EN
export LC_MONETARY=$EU
export LC_MESSAGES=$EN
export LC_PAPER=$EN
export LC_NAME=$EN
export LC_ADDRESS=$ES
export LC_TELEPHONE=$ES
export LC_MEASUREMENT=$EU
export LC_IDENTIFICATION=$ES
export LC_ALL=$EN

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
# KEYBOARD_LAYOUT_EXT="es";
KEYBOARD_LAYOUT_EXT="en";

# SET KEYBOARD LAYOUT
setKeyboardLayout $KEYBOARD_LAYOUT_EXT;

# DISPLAYS
DISPLAY_MAIN="eDP-1-1"
DISPLAY_EXT="HDMI-1-1"
export BRIGHTNESS=1.4

# KEYBOARD CONFIG - Satechi MX Keyboards
# SET: SWAP WIN-KEYS for CTRL-KEYS
setxkbmap -symbols "pc+us(mac)+us(altgr-intl):2+es(mac):3+inet(evdev)+ctrl(swap_lwin_lctl)+ctrl(swap_rwin_rctl)"

