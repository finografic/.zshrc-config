# ============================================================================ #
# JEST DEV
# ============================================================================ #

# JEST - CLEAR CACHE ON INIT
jest --clearCache >/dev/null 2>&1

# NOTE: JEST_OFFICE V2 - USES mfe-scripts AS IN package.json

function j() {
  mfe_scripts_cmd=$(echo "$(which npm) run test -- --watch")
  if [[ "$2" != "" ]]; then
    $mfe_scripts_cmd "$1" -t "$2"
  elif [[ "$1" != "" ]]; then
    $mfe_scripts_cmd "$1"
  else
    npm run test:coverage -- --runInBand
  fi
}


function j2() {
  mfe_scripts_cmd=$([[ -f "node_modules/@sage/mfe-scripts/src/bin/mfe-scripts.js" ]] && echo 'node_modules/.bin/jest' || echo 'npx jest')
  if [[ "$2" != "" ]]; then
    $mfe_scripts_cmd "$1" -t "$2" --setupFilesAfterEnv ./src/setupTests.ts   --watch
  elif [[ "$1" != "" ]]; then
    $mfe_scripts_cmd "$1" --setupFilesAfterEnv ./src/setupTests.ts --watch
  else
    npm run test:coverage -- --runInBand
  fi
}


# JEST RUN - FOR GAC UI (UTC TZ)
function jgac() {
  if [[ "$1" > "" ]]; then
    TZ=UTC npm test -- --testPathPattern="$1"
  else
    echo "\n${_y}⚠️   NO TEST-PATTERN SUPPLIED\n"
  fi
}

# JEST SNAP GENERATION - FOR GAC UI (UTC TZ)
function jsnaps() {
  if [[ "$1" > "" ]]; then
    TZ=UTC npm test -- -u --testPathPattern="$1"
  else
    echo "\n${_y}⚠️   NO TEST-PATTERN SUPPLIED\n"
  fi
}
