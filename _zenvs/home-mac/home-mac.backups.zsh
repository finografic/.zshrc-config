# ============================================================================ #
# DEFINE CONFIG SOUCRES + DESTINATIONS ======================================= #
# ============================================================================ #

configurations=(
    # FOLDERS
    "${HOME}/.config/.iterm2"
    "${HOME}/.config/karabiner"
    "${HOME}/.config/verdaccio"
    "${HOME}/configs/configs-apps"
    # FILES
    "${HOME}/.zshrc"
    "${HOME}/.gitconfig"
);

destinations=(
    "/Volumes/GoogleDrive/My Drive/⚙️ configs-macos"
    "${HOME}/os-setup/__configs-macos"
);

# ============================================================================ #
# CONDITIONAL TITLE MESSAGE ================================================== #
# ============================================================================ #

matches=$((0));

for DESTINATION in "${destinations[@]}"; do
  for CONFIG in "${configurations[@]}"; do
    [[ -d "${DESTINATION}" && -d "${CONFIG}" ]] && matches=$(($matches + 1));
    [[ -d "${DESTINATION}" && -f "${CONFIG}" ]] && matches=$(($matches + 1));
  done;
done;

(($matches > 0)) && echo $_grey;
(($matches > 0)) && echo "Backing up to Google Drive..."
(($matches > 0)) && echo $_0;

# ============================================================================ #
# BACKUP APP CONFIGS ========================================================= #
# ============================================================================ #

for DESTINATION in "${destinations[@]}"; do
  if [ -d "${DESTINATION}" ]; then
    # CONFIG - FOLDERS
    for CONFIG in "${configurations[@]}"; do
      if [ -d "${CONFIG}" ]; then
        rm -fr "${DESTINATION}/${CONFIG}"
        cp -R "${CONFIG}" "${DESTINATION}";
      fi
    done;
    # CONFIG - FILES
    for CONFIG in "${configurations[@]}"; do
      if [ -f "${CONFIG}" ]; then
        rm -fr "${DESTINATION}/${CONFIG}"
        cp -R "${CONFIG}" "${DESTINATION}";
      fi
    done;
  fi
done;


# ============================================================================ #
# ATOM CONFIG ================================================================ #
# ============================================================================ #

for DESTINATION in "${destinations[@]}"; do
  if [ -d "${DESTINATION}" ]; then
    cp $HOME/.atom/styles.less ${DESTINATION}/.atom;
    cp $HOME/.atom/config.cson ${DESTINATION}/.atom;
    cp $HOME/.atom/keymap.cson ${DESTINATION}/.atom;
    cp -r $HOME/.atom/packages ${DESTINATION}/.atom;
  fi
done;

# ============================================================================ #
# MOOM CONFIG ================================================================ #
# ============================================================================ #

for DESTINATION in "${destinations[@]}"; do
  if [ -d "${DESTINATION}" ]; then
    defaults export com.manytricks.Moom "${DESTINATION}/Moom.plist";
  fi
done;
