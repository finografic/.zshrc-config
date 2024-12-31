# DEFINE PATHS: DISTINATION
declare -a CONFIG_DESTINATIONS=(
  "/Volumes/GoogleDrive/My Drive/⚙️ configs-macos"
  "$HOME/os-setup/__configs-macos"
  "$HOME/Documents/configs"
)

# for CONFIG_DESTINATION in "${CONFIG_DESTINATIONS[@]}"; do
#   if [ -d "$CONFIG_DESTINATION" ]; then

#     echo "${_gray}Making config back-ups to... ${_g}$CONFIG_DESTINATION${_0}";

#     declare -a configFiles=(
#       "$HOME/.zshrc"
#       "$HOME/.config/iterm2"
#       "$HOME/.config/karabiner"
#       # "$HOME/Documents/configs/*.*"
#       # "$HOME/Documents/configs"
#     )

#     # echo "\n ======= $CONFIG_DESTINATION ======== \n"

#     for configFile in "${configFiles[@]}"; do
#       if [ -d "$configFile" ]; then
#         rm -fr "$CONFIG_DESTINATION/$configFile";
#         cp -R "$configFile" "$CONFIG_DESTINATION";
#       elif [ -f "$configFile" ]; then
#         rm -fr "$CONFIG_DESTINATION/$configFile";
#         cp -R "$configFile" $CONFIG_DESTINATION;
#       fi
#     done

#   fi;
# done;
