echo $_g; # GREEN
echo "Backing up to OneDrive..."
echo $_0;


# TODO: CHECK IF DEST FOLDER EXISTS + CREATE, IF NOT !!!!

# DEFINE PATHS
export APP_CONFIGS_SOURCE="$HOME/.config";
export APP_CONFIGS_DEST="$HOME/OneDrive - Sage Software, Inc/Apps";

export APP_CONFIGS_USER_SOURCE="$HOME/Documents/configs"
# export APP_CONFIGS_USER_DEST="$HOME/OneDrive - Sage Software, Inc/Apps";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a configFiles=(
    "iterm2"
    "karabiner"
    "verdaccio",
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$APP_CONFIGS_SOURCE/${configFile}" ]; then
        echo "\n ======= $configFile ======== \n";
        rm -fr "$APP_CONFIGS_DEST/${configFile}"
        cp -R "$APP_CONFIGS_SOURCE/${configFile}" $APP_CONFIGS_DEST;
    fi
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a configFiles=(
    "$HOME/.zshrc"
    "${APP_CONFIGS_USER_SOURCE}/*.*"
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$configFile" ]; then
        rm -fr "$APP_CONFIGS_DEST/${configFile}"
        cp -R "${configFile}" $APP_CONFIGS_DEST;
    fi
done

# BACKUP OTHER MISC APP CONFIGS
cp ${APP_CONFIGS_USER_SOURCE}/.gitconfig $APP_CONFIGS_DEST;
cp ${APP_CONFIGS_USER_SOURCE}/*.* $APP_CONFIGS_DEST;

# Atom - DEPRECATED
# cp $HOME/.atom/styles.less $APP_CONFIGS_DEST/.atom;
# cp $HOME/.atom/config.cson $APP_CONFIGS_DEST/.atom;
# cp $HOME/.atom/keymap.cson $APP_CONFIGS_DEST/.atom;
# cp -r $HOME/.atom/packages $APP_CONFIGS_DEST/.atom; # TAKES TOO LONG !!!

# Moom
defaults export com.manytricks.Moom $APP_CONFIGS_DEST/Moom.plist
# Moom: to import exported settings, quit app and run:
# defaults import com.manytricks.Moom ./Moom.plist
