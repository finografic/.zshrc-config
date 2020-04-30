# AUDIO

# HOME AUDIO "SINKS" / SOURCES
# 0       alsa_output.pci-0000_00_03.0.hdmi-stereo        module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
# 1       alsa_output.pci-0000_00_1b.0.analog-stereo      module-alsa-card.c      s16le 2ch 44100Hz       RUNNING

function is_headphones_available() {
    HEADPHONES_UNAVAILABLE=`echo $(pactl list sinks | grep "analog-output-headphones*") | grep "not available" | wc -l`;
    if [ $HEADPHONES_UNAVAILABLE = 1 ]; then HEADPHONES_AVAILABLE=0; else HEADPHONES_AVAILABLE=1; fi
    export HEADPHONES_UNAVAILABLE;
    export HEADPHONES_AVAILABLE;
    if [ $HEADPHONES_AVAILABLE = 1 ]; then 
        echo -e "${_c}HEADPHONES${_0} audio: ${_g}available${_0}"; 
    else 
        echo "${_c}HEADPHONES${_0} audio: ${_r}not available${_0}"; 
    fi;
}

function get_audio_root() {
    AUDIO_ROOT=`echo $(pactl list short sinks | grep -v "hdmi" | awk '{print $1}')`;
    echo $AUDIO_ROOT;
}

function move_audio_to_root() {
    echo -e "${_y}Switching audio to MAIN...${_0}";
    export AUDIO_ROOT=`echo $(pactl list short sinks | grep -v "hdmi" | awk '{print $1}')`;
    pactl list short sink-inputs | awk '{print $1}' | xargs -I {} pacmd move-sink-input {} $1 $AUDIO_ROOT;
}

function move_audio_to_hdmi() {
    echo -e "${_y}Switching audio to HDMI...${_0}";
    export AUDIO_HDMI=`echo $(pactl list short sinks | grep "hdmi" | awk '{print $1}')`;
    pactl list short sink-inputs | awk '{print $1}' | xargs -I {} pacmd move-sink-input {} $1 $AUDIO_HDMI;
}

# CHECK AND SET AUDIO - MAIN FUNCTION !!
function audio() {
    # ARE HEADPHONES PLUGGED IN ??
    is_headphones_available;

    # SWITCH AUDIO, DEPENDING...
    if [ $HDMI_AVAILABLE = 1 ] && [ $HEADPHONES_AVAILABLE = 0 ]; then 
        move_audio_to_hdmi;
    elif [ $HDMI_AVAILABLE = 1 ] && [ $HEADPHONES_AVAILABLE = 1 ]; then 
        move_audio_to_hdmi;
    else
        # WILL DEFAULT TO HEADPHONES, IF PLUGGED IN ;)
        move_audio_to_root;
    fi;
}

audio;

function AUDIO_EXAMPLES() {

  # 1. LIST "SINKS" (OUTPUTS)
  pactl list short sinks
  pactl list short sinks | awk '{print $1}' # INDEX
  pactl list short sinks | awk '{print $2}' # NAME

  # GET INDEX OF HDMI
  pactl list short sinks | grep "hdmi" | awk '{print $1}'

  # GET INDEX OF NOT-HDMI
  pactl list short sinks | grep -v "hdmi" | awk '{print $1}'

  # 2. LIST SOURCES
  pactl list short sink-inputs
  24     1       176     protocol-native.c       float32le 2ch 44100Hz
  28     1       195     protocol-native.c       float32le 2ch 44100Hz

  pacmd list-sink-inputs | awk '/index:/{print $2}'
  24
  28

  # 3. MOVE INPUT
  pactl list short sink-inputs | awk '{print $1}'| xargs -I {} pacmd move-sink-input {} $1 0

}

