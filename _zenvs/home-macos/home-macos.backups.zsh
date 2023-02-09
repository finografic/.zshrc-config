echo $_g; # GREEN
echo "Backing up to Google Drive..."
echo $_0;

# DEFINE PATHS
export APP_CONFIGS_SOURCE="$HOME/.config";
export APP_CONFIGS_DEST_1="/Volumes/GoogleDrive/My Drive/⚙️ configs-macos";
export APP_CONFIGS_DEST_2="$HOME/os-setup/__configs-macos";

# BACKUP APP CONFIGS LOCATED IN $HOME/.config

declare -a configFiles=(
    "iterm2"
    "karabiner"
    "verdaccio",
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$APP_CONFIGS_SOURCE/${configFile}" ]; then
        echo "\n ======= $configFile ======== \n";
        # DESTINATION 1
        rm -fr "$APP_CONFIGS_DEST_1/${configFile}"
        cp -R "$APP_CONFIGS_SOURCE/${configFile}" $APP_CONFIGS_DEST_1;
        # DESTINATION 2
        rm -fr "$APP_CONFIGS_DEST_2/${configFile}"
        cp -R "$APP_CONFIGS_SOURCE/${configFile}" $APP_CONFIGS_DEST_2;
    fi
done

# BACKUP APP CONFIGS LOCATED IN OTHER PATHS

declare -a configFiles=(
    "$HOME/.zshrc"
    "$HOME/Documents/configs/*.*"
)

for configFile in "${configFiles[@]}"; do
    if [ -f "$configFile" ]; then
        # DESTINATION 1
        rm -fr "$APP_CONFIGS_DEST_1/${configFile}"
        cp -R "${configFile}" $APP_CONFIGS_DEST_1;
        # DESTINATION 2
        rm -fr "$APP_CONFIGS_DEST_2/${configFile}"
        cp -R "${configFile}" $APP_CONFIGS_DEST_2;
    fi
done

# BACKUP OTHER MISC APP CONFIGS
cp $HOME/Documents/configs/.gitconfig $APP_CONFIGS_DEST_1;
cp $HOME/Documents/configs/.gitconfig $APP_CONFIGS_DEST_2;
cp $HOME/Documents/configs/*.* $APP_CONFIGS_DEST_1;
cp $HOME/Documents/configs/*.* $APP_CONFIGS_DEST_2;

# Atom - DEPRECATED
# cp $HOME/.atom/styles.less $APP_CONFIGS_DEST_1/.atom;
# cp $HOME/.atom/config.cson $APP_CONFIGS_DEST_1/.atom;
# cp $HOME/.atom/keymap.cson $APP_CONFIGS_DEST_1/.atom;
# cp -r $HOME/.atom/packages $APP_CONFIGS_DEST_1/.atom;
# cp $HOME/.atom/styles.less $APP_CONFIGS_DEST_2/.atom;
# cp $HOME/.atom/config.cson $APP_CONFIGS_DEST_2/.atom;
# cp $HOME/.atom/keymap.cson $APP_CONFIGS_DEST_2/.atom;
# cp -r $HOME/.atom/packages $APP_CONFIGS_DEST_2/.atom;

# Moom
defaults export com.manytricks.Moom $APP_CONFIGS_DEST_1/Moom.plist
defaults export com.manytricks.Moom $APP_CONFIGS_DEST_2/Moom.plist
# Moom: to import exported settings, quit app and run:
# defaults import com.manytricks.Moom ./Moom.plist
