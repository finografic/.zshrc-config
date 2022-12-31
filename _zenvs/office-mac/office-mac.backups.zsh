echo $_g; # GREEN
echo "Backing up to OneDrive..."
echo $_0;

# DEFINE PATHS
export APP_CONFIGS_SOURCE="${HOME}/.config";
export APP_CONFIGS_DEST="${HOME}/OneDrive - Sage Software, Inc/Apps";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a configFiles=(
    "iterm2"
    "karabiner"
    "verdaccio",
)

for configFile in "${configFiles[@]}"; do
    if [ -f "${APP_CONFIGS_SOURCE}/${configFile}" ]; then
        echo "\n ======= $configFile ======== \n";
        rm -fr "${APP_CONFIGS_DEST}/${configFile}"
        cp -R "${APP_CONFIGS_SOURCE}/${configFile}" ${APP_CONFIGS_DEST};
    fi
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a configFiles=(
    "${HOME}/.zshrc"
    "${HOME}/Documents/configs-apps/*.*"
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$configFile" ]; then
        rm -fr "${APP_CONFIGS_DEST}/${configFile}"
        cp -R "${configFile}" ${APP_CONFIGS_DEST};
    fi
done

# BACKUP OTHER MISC APP CONFIGS
cp $HOME/Documents/configs-apps/.gitconfig ${APP_CONFIGS_DEST};
cp $HOME/Documents/configs-apps/*.* ${APP_CONFIGS_DEST};

# Atom
cp $HOME/.atom/styles.less ${APP_CONFIGS_DEST}/.atom;
cp $HOME/.atom/config.cson ${APP_CONFIGS_DEST}/.atom;
cp $HOME/.atom/keymap.cson ${APP_CONFIGS_DEST}/.atom;
cp -r $HOME/.atom/packages ${APP_CONFIGS_DEST}/.atom;

# Moom
defaults export com.manytricks.Moom ${APP_CONFIGS_DEST}/Moom.plist
# Moom: to import exported settings, quit app and run:
# defaults import com.manytricks.Moom ./Moom.plist
