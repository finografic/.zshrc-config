echo $_g; # GREEN
echo "Backing up to OGoogle Drive..."
echo $_0;

# DEFINE PATHS
export ONEDRIVE_APP_CONFIGS="${HOME}/gDrive/configs";
export LOCAL_APP_CONFIGS="${HOME}/.config";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a appConfigs=(
  "iterm2"
  "karabiner"
  "verdaccio"
)

for appConfig in "${appConfigs[@]}"; do
  rm -fr "${ONEDRIVE_APP_CONFIGS}/${appConfig}"
  cp -R "${LOCAL_APP_CONFIGS}/${appConfig}" ${ONEDRIVE_APP_CONFIGS};
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a appConfigs=(
  "${HOME}/.zshrc"
  "${HOME}/Documents/configs_apps/*.*"
)

for appConfig in "${appConfigs[@]}"; do
  rm -fr "${ONEDRIVE_APP_CONFIGS}/${appConfig}"
  cp -R "${appConfig}" ${ONEDRIVE_APP_CONFIGS};
done

# BACKUP OTHER MISC APP CONFIGS
cp $HOME/Documents/configs_apps/.gitconfig ${ONEDRIVE_APP_CONFIGS};
cp $HOME/Documents/configs_apps/*.* ${ONEDRIVE_APP_CONFIGS};
