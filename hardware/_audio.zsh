# AUDIO

# HOME AUDIO "SINKS" / SOURCES
# 0       alsa_output.pci-0000_00_03.0.hdmi-stereo        module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
# 1       alsa_output.pci-0000_00_1b.0.analog-stereo      module-alsa-card.c      s16le 2ch 44100Hz       RUNNING

function headphones_availability() {
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
  AUDIO_DEVICE_ROOT=`echo $(pactl list short sinks | grep -v "hdmi" | awk '{print $1}')`;
  echo $AUDIO_DEVICE_ROOT;
}

function audio_root() {
  if [ $HEADPHONES_AVAILABLE = 1 ]; then CURRENT_AUDIO_DEVICE="headphones"; else CURRENT_AUDIO_DEVICE="internal speaker"; fi
  export CURRENT_AUDIO_DEVICE;
  echo "${_y}Switching audio to ${CURRENT_AUDIO_DEVICE}...${_0}";
  export AUDIO_DEVICE_ROOT=`echo $(pactl list short sinks | grep -v "hdmi" | awk '{print $1}')`;
  pactl list short sink-inputs | awk '{print $1}' | xargs -I {} pacmd move-sink-input {} $1 $AUDIO_DEVICE_ROOT;
}

function audio_hdmi() {
  CURRENT_AUDIO_DEVICE="HDMI";
  export CURRENT_AUDIO_DEVICE;
  echo "${_y}Switching audio to ${CURRENT_AUDIO_DEVICE}...${_0}";
  export AUDIO_HDMI=`echo $(pactl list short sinks | grep "hdmi" | awk '{print $1}')`;
  pactl list short sink-inputs | awk '{print $1}' | xargs -I {} pacmd move-sink-input {} $1 $AUDIO_HDMI;
}

# CHECK AND SET AUDIO - MAIN FUNCTION !!
function audio() {
  # ARE HEADPHONES PLUGGED IN ??
  headphones_availability;
  # echo "\n${_grey}AUDIO VARIABLE PASSED: ${@}${_0}";
  # echo "${_grey}HEADPHONES_AVAILABLE = ${HEADPHONES_AVAILABLE}${_0}";
  # echo "${_grey}HEADPHONES_UNAVAILABLE = ${HEADPHONES_UNAVAILABLE}${_0}\n";

  if [[ $@ == "root" || $@ == "main" ]] then
      audio_root;
  elif [[ $@ == "hdmi" ]] then
      audio_hdmi;
  else
    # SWITCH AUDIO, DEPENDING...
    if   [ $HDMI_AVAILABLE = 1 ] && [ $HEADPHONES_AVAILABLE = 0 ]; then
      echo "${_grey}CASE 1: HDMI available + headphones not available${_0}"
      audio_hdmi;
    elif [ $HDMI_AVAILABLE = 1 ] && [ $HEADPHONES_AVAILABLE = 1 ]; then
      echo "${_grey}CASE 2: HDMI available + headphones available${_0}"
      audio_root;
    else
      echo "${_grey}CASE 3: DEFAULT (root audio)${_0}"
      # WILL DEFAULT TO HEADPHONES, IF PLUGGED IN ;)
      audio_root;
    fi;
  fi

}

# INIT AUDIO CONFIG
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

