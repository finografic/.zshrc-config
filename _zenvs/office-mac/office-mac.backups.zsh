echo $_g; # GREEN
echo "Backing up to OneDrive..."
echo $_0;

# DEFINE PATHS
export ONEDRIVE_APP_CONFIGS="${HOME}/OneDrive - Sage Software, Inc/Apps";
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
)

for appConfig in "${appConfigs[@]}"; do
  rm -fr "${ONEDRIVE_APP_CONFIGS}/${appConfig}"
  cp -R "${appConfig}" ${ONEDRIVE_APP_CONFIGS};
done
