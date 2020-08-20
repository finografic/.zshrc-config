#############################################
############ FUNCTIONS: SYSTEM ##############
#############################################

# FIX FOR KDE PLASMA DISPLAY BUG
function kde_restart_plasma() {
    killall plasmashell;
    kstart5 plasmashell;
}

alias kde-restart=kde_restart_plasma;
alias kde=kde_restart_plasma;
