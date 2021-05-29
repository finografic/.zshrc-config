echo $_g; # GREEN
echo "Backing up to Google Drive..."
echo $_0;

# DEFINE PATHS
export APP_CONFIGS_DEST="${HOME}/gDrive/configs";
export LOCAL_APP_CONFIGS="${HOME}/.config";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a appConfigs=(
  "iterm2"
  "karabiner"
  "verdaccio"
)

for appConfig in "${appConfigs[@]}"; do
  rm -fr "${APP_CONFIGS_DEST}/${appConfig}"
  cp -R "${LOCAL_APP_CONFIGS}/${appConfig}" ${APP_CONFIGS_DEST};
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a appConfigs=(
  "${HOME}/.atom/styles.less"
  "${HOME}/.zshrc"
  "${HOME}/Documents/configs_apps/*.*"
)

for appConfig in "${appConfigs[@]}"; do
  rm -fr "${APP_CONFIGS_DEST}/${appConfig}"
  cp -R "${appConfig}" ${APP_CONFIGS_DEST};
done

# BACKUP OTHER MISC APP CONFIGS
cp $HOME/Documents/configs_apps/.gitconfig ${APP_CONFIGS_DEST};
cp $HOME/Documents/configs_apps/*.* ${APP_CONFIGS_DEST};

# Atom
cp $HOME/.atom/styles.less ${APP_CONFIGS_DEST}/.atom;
cp $HOME/.atom/packages ${APP_CONFIGS_DEST}/.atom;
