echo $_g; # GREEN
echo "Backing up to OneDrive..."
echo $_0;

# DEFINE PATHS
export ONEDRIVE_APP_CONFIGS="${HOME}/OneDrive - Sage Software, Inc/Apps";
export LOCAL_APP_CONFIGS="${HOME}/.config";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a configFiles=(
    "iterm2"
    "karabiner"
    "verdaccio",
)

for configFile in "${configFiles[@]}"; do
    if [ -f "${LOCAL_APP_CONFIGS}/${configFile}" ]; then
        echo "\n ======= $configFile ======== \n";
        rm -fr "${ONEDRIVE_APP_CONFIGS}/${configFile}"
        cp -R "${LOCAL_APP_CONFIGS}/${configFile}" ${ONEDRIVE_APP_CONFIGS};
    fi
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a configFiles=(
    "${HOME}/.zshrc"
    "${HOME}/Documents/configs_apps/*.*"
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$configFile" ]; then
        rm -fr "${ONEDRIVE_APP_CONFIGS}/${configFile}"
        cp -R "${configFile}" ${ONEDRIVE_APP_CONFIGS};
    fi

done

# BACKUP OTHER MISC APP CONFIGS
cp $HOME/Documents/configs_apps/.gitconfig ${ONEDRIVE_APP_CONFIGS};
cp $HOME/Documents/configs_apps/*.* ${ONEDRIVE_APP_CONFIGS};
defaults export com.manytricks.Moom ${ONEDRIVE_APP_CONFIGS}/Moom.plist
