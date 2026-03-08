REPOS="$HOME/dev_projects"

export CPATH=$(xcrun --show-sdk-path)/usr/include

function run() {
  # requires "ntl" node package installed globally
  echo "\n"
  ntl --info --size 20
}

###############################
##########  NEW 2026  #########
###############################


# ------------------------------------------------------------------------- #
# Recursively remove all `node_modules` directories from a given path.
# Usage: _clean_node_modules [--dry-run|-n] [--force|-f] [path]
# Defaults: path="." (current working directory)
# Options:
#  --dry-run, -n   : list what would be removed without deleting
#  --force, -f     : remove without prompting per-folder
# Notes:
#  - Matches true directories and symlinks named "node_modules".
#  - Uses `rm -rf --` so dotfiles, dot-folders and symlinks inside
#    each `node_modules` are removed without leaving artifacts.
# ------------------------------------------------------------------------- #

_clean_node_modules() {
  local target="."
  local dry_run=0
  local force=0

  # Parse args
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run|-n) dry_run=1; shift ;;
      --force|-f) force=1; shift ;;
      --) shift; target="$1"; shift; break ;;
      *) target="$1"; shift ;;
    esac
  done

  if [ -z "$target" ]; then target="."; fi
  if [ ! -e "$target" ]; then
    echo "Target does not exist: $target"
    return 1
  fi

  echo "Searching for node_modules under: $target"

  # Collect node_modules directories (real dirs and symlinks named node_modules)
  local -a matches
  local p

  # Directories named node_modules (prune so find doesn't descend into them)
  while IFS= read -r -d '' p; do
    matches+=("$p")
  done < <(find "$target" -name 'node_modules' \( -type d -o -type l \) -prune -print0 2>/dev/null)

  if [ ${#matches[@]} -eq 0 ]; then
    echo "No node_modules found under: $target"
    return 0
  fi

  printf "Found %d node_modules locations\n" "${#matches[@]}"

  for p in "${matches[@]}"; do
    if [ $dry_run -eq 1 ]; then
      echo "[DRY-RUN] rm -rf -- $p"
      continue
    fi

    if [ $force -ne 1 ]; then
      printf "Delete %s ? [y/N]: " "$p"
      read -r ans
      case "$ans" in
        y|Y|yes|YES|Yes) ;;
        *) echo "Skipping: $p"; continue ;;
      esac
    fi

    # Use rm -rf -- to ensure removal of dotfiles/folders and symlinks
    rm -rf -- "$p"
    if [ $? -eq 0 ]; then
      echo "Removed: $p"
    else
      echo "Failed to remove: $p" >&2
    fi
  done
}

alias _cnm="_clean_node_modules"



function min() {
  # Pass-through: allow minify help/version without requiring a file.
  # (Your screenshot shows `min --help`, `min -h`, etc.)
  if [[ "$1" == "help" || "$1" == "-h" || "$1" == "--help" ]]; then
    command minify --help
    return $?
  fi
  if [[ "$1" == "version" || "$1" == "-v" || "$1" == "--version" ]]; then
    command minify --version
    return $?
  fi

  local input_file=""
  local -a minify_args

  # Allow flags either before or after the input file by selecting the first
  # argument that is an existing file as the input.
  local arg
  for arg in "$@"; do
    if [[ -z "$input_file" && -f "$arg" ]]; then
      input_file="$arg"
    else
      minify_args+=("$arg")
    fi
  done

  # If no file detected, either (a) it's flags-only (pass through), or (b) user
  # intended a file path that doesn't exist.
  if [[ -z "$input_file" ]]; then
    local nonflag=""
    for arg in "$@"; do
      if [[ "$arg" != -* ]]; then
        nonflag="$arg"
        break
      fi
    done

    if [[ -z "$nonflag" ]]; then
      command minify "$@"
      return $?
    fi

    input_file="$1"
    shift 2>/dev/null
    minify_args=("$@")
  fi

  if [[ -z "$input_file" ]]; then
    echo "\n${_y}⚠️   NO INPUT FILE SUPPLIED\n"
    echo "Usage: min <file> [minify options...]\n"
    return 1
  fi

  if [[ ! -f "$input_file" ]]; then
    echo "\n${_r}❌ File not found:${_0} $input_file\n"
    return 1
  fi

  local dir base out_file
  dir="${input_file:h}"
  base="${input_file:t}"

  # Decide output path:
  # - if filename already contains a .min. segment (or ends with .min), default to overwrite
  # - otherwise write a sibling file with .min inserted before the last extension
  if [[ "$base" == *.min.* || "$base" == *.min ]]; then
    out_file="$input_file"
  else
    if [[ "$dir" == "." ]]; then
      if [[ "$base" == *.* ]]; then
        out_file="${base:r}.min.${base:e}"
      else
        out_file="${base}.min"
      fi
    else
      if [[ "$base" == *.* ]]; then
        out_file="${dir}/${base:r}.min.${base:e}"
      else
        out_file="${dir}/${base}.min"
      fi
    fi
  fi

  # If the target exists, prompt for overwrite; if declined, choose a suffixed name.
  if [[ -e "$out_file" ]]; then
    if [[ -t 0 ]]; then
      echo "\n${_y}⚠️  Target exists:${_0} $out_file"
      local reply
      read -q "reply?Overwrite? [y/N] "
      echo ""
      if [[ ! "$reply" =~ '^[Yy]$' ]]; then
        local out_dir out_base name_part ext candidate
        local -i n
        out_dir="${out_file:h}"
        out_base="${out_file:t}"
        n=1

        # Prefer app.min.js -> app.min-1.js, foo.min -> foo.min-1
        while true; do
          if [[ "$out_base" == *.min.* ]]; then
            name_part="${out_base%.*}"
            ext="${out_base##*.}"
            candidate="${name_part}-${n}.${ext}"
          else
            candidate="${out_base}-${n}"
          fi

          if [[ "$out_dir" != "." ]]; then
            candidate="${out_dir}/${candidate}"
          fi

          if [[ ! -e "$candidate" ]]; then
            out_file="$candidate"
            break
          fi
          n=$((n + 1))
        done
      fi
    else
      echo "\n${_y}⚠️  Target exists (non-interactive; overwriting):${_0} $out_file\n"
    fi
  fi

  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/minify.XXXXXXXX")" || return 1

  # minify writes to stdout; capture to a temp file first so overwrites are safe.
  if ! command minify "${minify_args[@]}" "$input_file" > "$tmp"; then
    local exit_code=$?
    rm -f "$tmp"
    echo "\n${_r}❌ minify failed (exit ${exit_code})${_0}\n"
    return $exit_code
  fi

  # If writing to an existing file, preserve perms/ownership by truncating + writing.
  if [[ -e "$out_file" ]]; then
    cat "$tmp" > "$out_file"
    rm -f "$tmp"
    if [[ "$out_file" == "$input_file" ]]; then
      echo "\n${_g}✅ Minified (overwrote):${_0} $out_file\n"
    else
      echo "\n${_g}✅ Minified (overwrote):${_0} $out_file\n"
    fi
  else
    mv -f "$tmp" "$out_file"
    if [[ "$out_file" == "$input_file" ]]; then
      echo "\n${_g}✅ Minified:${_0} $out_file\n"
    else
      echo "\n${_g}✅ Minified:${_0} $input_file  →  $out_file\n"
    fi
  fi
}

# Wrapper: measure disk usage before and after running the cleaner
clean-node-modules-report() {
  # Compute size in kilobytes, fallback to 0
  SIZE_A_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
  SIZE_A=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A_KB:-0})/1024}")

  # Run the existing cleaner (allow passing options/args)
  clean-node-modules "$@"

  # Recompute size after cleanup
  SIZE_B_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
  SIZE_B=$(awk "BEGIN{printf \"%.1f\", (${SIZE_B_KB:-0})/1024}")

  # Compute saved (may be negative if size increased)
  SAVED=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A} - ${SIZE_B})}")

  # Output results with colours
  echo "${_grey}before clean: ${SIZE_A} MB${_0}"
  echo "${_grey}after clean: ${SIZE_B} MB${_0}"
  echo "${_g}space saved: ${SAVED} MB${_0}"

  # Export variables for interactive inspection
  export SIZE_A SIZE_B SAVED
}


###############################
############  NPM  ############
###############################


# ALIASES THAT TAKE PARAMETERS
function versions() {
  # ALL THE SAME ??
  npm view "$1" versions --json
  # npm info "$1" versions --json
  # npm show "$1" versions --json
  # yarn info "$1" versions
}

# NPM - GET PACKAGE VERSION
function v() {
  CURRENT_VERSION=$($1 --version)
  LATEST_VERSION=$(latest-version $1)
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:"
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION"
  else
    echo "\e[1mCurrent version of \e[1m\e[36m$1\e[0m is up to date."
    echo "\e[32m\e[1m$CURRENT_VERSION"
  fi
}

function latest() {
  latest-version $1
}

function update() {

  # GET VERSIONS
  CURRENT_VERSION=$($1 --version)
  LATEST_VERSION=$(latest-version $1)

  # OUTPUT INFO
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:"
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION"
  else
    echo "\e[0mCurrent version of \e[1m\e[36m$1\e[0m is latest version."
    echo "\e[32m\e[1m$CURRENT_VERSION"
  fi

  # UPDATE ??
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]]; then
    echo "\n\e[0mUpdating global package \e[1m\e[36m$1\e[1m\e[0m ...\n"
    npm i -g $1@$LATEST_VERSION
  fi
}

#########################################
#########  CLEAN node_modules  ##########
#########################################

# DELETE ALL node_modules RECURSIVELY
clean-node-modules() {
  echo "\n${_c}🔍 Finding node_modules directories...${_0}"

  # Get directories and sort by path depth (shortest first)
  dirs=($(fd -H -I "^node_modules$" -t d | awk '{print length, $0}' | sort -n | cut -d" " -f2-))

  # Track total size and failed deletions
  failed_dirs=()

  # If no directories found
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "${_w}No node_modules directories found.${_0}\n"
    return 0
  fi

  # Show total count
  echo "${_y}Found ${#dirs[@]} node_modules directories.${_0}\n"

  # Process each directory
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      # Get size before deletion attempt
      size=$(du -sh "$dir" 2>/dev/null | cut -f1)
      size_bytes=$(du -s "$dir" 2>/dev/null | cut -f1)

      if [ ! -z "$size" ]; then
        echo "\n${_grey}🗑️  Removing $dir (size: $size)${_0}\n"

        # Try to remove with sudo if normal remove fails
        if ! rm -rf "$dir" 2>/dev/null; then
          echo "${_y}⚠️  Permission denied, trying with sudo...${_0}"
          sudo rm -rf "$dir" || {
            echo "${_r}❌ Failed to remove: $dir${_0}"
            failed_dirs+=("$dir")
          }
        fi
      fi
    fi
  done

  # Final summary
  echo "\n${_g}✨ Cleanup complete!${_0}\n"

  # Report any failures
  if [ ${#failed_dirs[@]} -gt 0 ]; then
    echo "\n${_y}Warning: The following directories had permission issues:${_0}"
    for failed in "${failed_dirs[@]}"; do
      echo "${_r}  - $failed${_0}"
    done
    echo "${_y}You might need to remove these manually with sudo${_0}"
  fi
}

# ORIG - ALIAS
# alias clean-node-modules='fd -H "^node_modules$" -t d -x rm -rf {}'

## OTHER fd USES..

# List matches first (safe preview)
# fd -H '^node_modules$' -t d

# Show size of each node_modules before deleting
# fd -H '^node_modules$' -t d -x du -sh {}

# Exclude specific paths
# fd -H '^node_modules$' -t d --exclude path/to/keep

###############################
############  NODE  ###########
###############################

alias kn='killall -9 node'

# NEW -GREAT!!- PAPCKAGE MANAGER
alias i="pnpm install"

#####################################
#########  REPO DEPLOY  ##########
#####################################

# DEPLOYMENT FOR REACT --> FINOGRAFIC-DEV.COM
# RUN FROM REPO ROOT
alias deploy="cross-env GENERATE_SOURCEMAP=false react-scripts build && mv build finografic-dev.com && rsync -avru --delete-before -e 'ssh -p 7822' ./finografic-dev.com ubuntu@REDACTED-IP:/var/www && rm finografic-dev.com -fr"

#####################################
#########  DEV + TESTING  ###########
#####################################

# CRONIC CRON ;)
cx() {
  pm2 stop cronic
  pm2 delete cronic
  cd $REPOS/cronic
  rm log/access.log
  rm log/error.log
  pm2 start
  pm2 log cronic
}


################################################
##################  GO LANG   ##################
################################################

export GO111MODULE=on

################################################
####################  MISC   ###################
################################################

# eval $( dircolors -b $HOME/bin/LS_COLORS );

#####################################
##############  LOGS  ###############
#####################################

# REPLACT cat WITH bat !!
# https://github.com/sharkdp/bat

# cat() {
#   bat $1
# }

lg() {
  if [[ $1 > "" ]]; then
    sudo multitail -n 500 $1
  else
    sudo lnav /var/log/syslog
  fi
}

# alias logs="tailc app/logs/prod.log"
alias logs-aa="sudo lnav /var/log/apache2/access.log"
alias logs-ae="sudo lnav /var/log/apache2/error.log"

tailc() {

  # save this file as tailc then
  # run as: $ tailc logs/supplier-matching-worker.log Words_to_highlight
  file=$1

  if [[ -n "$2" ]]; then
    color='
      // {print "\033[37m" $0 "\033[39m"}
      /(WARN|WARNING)/ {print "\033[1;33m" $0 "\033[0m"}
      /(ERROR|CRIT)/ {print "\033[1;31m" $0 "\033[0m"}
      /('$2')/ {print "\033[1;32m" $0 "\033[0m"}
      '
  else
    color='
      // {print "\033[37m" $0 "\033[39m"}
      /(WARN|WARNING)/ {print "\033[1;33m" $0 "\033[0m"}
      /(ERROR|CRIT)/ {print "\033[1;31m" $ec0 "\033[0m"}
      '
  fi

  tail -5000f $file | awk "$color"

  # Colors
  # 30 - black   34 - blue          40 - black    44 - blue
  # 31 - red     35 - magenta       41 - red      45 - magenta
  # 32 - green   36 - cyan          42 - green    46 - cyan
  # 33 - yellow  37 - white         43 - yellow   47 - white

}

# alias logs='tailc app/logs/prod.log'

# list new/recent logs (1 DAY)
# alias logsr='sudo find /var/log -mtime -1 -ls'
function logsr() {
  # VAR_SINCE={$1}/24);
  VAR_SINCE=0.5
  sudo find /var/log -mtime -$VAR_SINCE -ls
}

##################################
##############  PM2   ############
##################################

function pm2da() {
  pm2 delete all
}

function pm2ll() {
  pm2 list --sort id:asc
}
