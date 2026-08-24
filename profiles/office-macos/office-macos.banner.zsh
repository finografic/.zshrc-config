# BANNER

# ASCII GENERATOR:
# https://www.askapache.com/online-tools/figlet-ascii/

echo $_O # ORANGE (256-color 208)

# STYLE: "smslant" (default when SPLASH_BANNER is unset in .env)
# cat << EOF
#    ____  ____________________________
#   / __ \/ ____/ ____/  _/ ____/ ____/
#  / / / / /_  / /_   / // /   / __/
# / /_/ / __/ / __/ _/ // /___/ /___
# \____/_/   /_/   /___/\____/_____/
# EOF

# Optional brand banner from .env (gitignored). See .env.example — SPLASH_BANNER.
# TEST: home-macos only for now; office-macos will own the real VALD banner.
function print-splash-banner-from-env() {
  [[ -n ${SPLASH_BANNER:-} ]] || return 1
  print -r -- "$SPLASH_BANNER"
}

if ! print-splash-banner-from-env; then
  cat <<'EOF'
   ____  ____________________________
  / __ \/ ____/ ____/  _/ ____/ ____/
 / / / / /_  / /_   / // /   / __/
/ /_/ / __/ / __/ _/ // /___/ /___
\____/_/   /_/   /___/\____/_____/
EOF
fi
unset -f print-splash-banner-from-env
