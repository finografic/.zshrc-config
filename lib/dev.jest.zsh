##################################
###########  JEST DEV  ###########
##################################

# JEST - CLEAR CACHE ON INIT
jest --clearCache >/dev/null 2>&1

# JEST - UNIT TESTING ALIAS !!!
# from: { index.js}
# to: { Component.js, package.json }

function j() {
  jest_cmd=$([[ -f "node_modules/.bin/jest" ]] && echo 'node_modules/.bin/jest' || echo 'npx jest')
  # jest --silent --verbose=false --bail
  if [[ "$2" != "" ]]; then
    # $jest_cmd "$1" -t "$2" --watch --verbose=false
    $jest_cmd "$1" -t "$2" --watch
  elif [[ "$1" != "" ]]; then
    # $jest_cmd "$1" --watch --verbose=false
    $jest_cmd "$1" --watch
  else
    npm run test:coverage -- --runInBand
  fi
}

function js() {
  jest_cmd=$([[ -f "node_modules/.bin/jest" ]] && echo 'node_modules/.bin/jest' || echo 'npx jest')
  # jest --silent --verbose=false --bail
  if [[ "$2" != "" ]]; then
    $jest_cmd "$1" -t "$2" --watch --silent
  elif [[ "$1" != "" ]]; then
    $jest_cmd "$1" --watch --silent
  else
    npm run test:coverage -- --runInBand
  fi
}

# *SCOPED* JEST COVERAGE - COVERAGE REPORT OF *ONLY* SPECFIED SCOPE
function jc() {
  if [[ "$1" > "" ]]; then
    npx jest --coverage --watch "$1"
  else
    echo "\n${_y}⚠️   NO FILENAME SUPPLIED\n"
  fi
}

# JEST SNAP GENERATION
function jsnaps() {
  if [[ "$1" > "" ]]; then
    npm test -- -u --testPathPattern="$1"
  else
    echo "\n${_y}⚠️   NO FILENAME SUPPLIED\n"
  fi
}



# ================================================================== #
# NOTE: jest logs..

function jlog() {
  if [[ "$2" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" -t "$2" >>JEST.log 2> >(tee JEST.log >&2)
  elif [[ "$1" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" >>JEST.log 2> >(tee JEST.log >&2)
  else
    npm run test:coverage -- --runInBand >>JEST.log 2> >(tee JEST.log >&2)
  fi
}

function jlog2() {
  if [[ "$2" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" -t "$2" --color=always | sed -r 'w /dev/stderr' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log
  elif [[ "$1" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" --color=always | sed -r 'w /dev/stderr' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log
  else
    npm run test:coverage -- --runInBand --color=always | sed -r 'w /dev/stderr' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log
  fi
}

function jlog3() {
  if [[ "$2" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" -t "$2" --color=always | tee >(sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log)
  elif [[ "$1" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" --color=always | tee >(sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log)
  else
    npm run test:coverage -- --runInBand ---color=always | tee >(sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' >>JEST.log)
  fi
}

function jlog4() {
  if [[ "$2" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" -t "$2" --color=always | tee >(sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g") >>JEST.log
  elif [[ "$1" > "" ]]; then
    node 'node_modules/.bin/jest' "$1" --color=always | tee >(sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g") >>JEST.log
  else
    npm run test:coverage -- --runInBand ---color=always | tee >(sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g") >>JEST.log
  fi
}
