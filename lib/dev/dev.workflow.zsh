# ============================================================================ #
# DEV WORKFLOW - misc dev helpers (everything from lib/dev.zsh that wasn't an
# npm/global-install helper — those moved to lib/node/node.globals.zsh)
# ============================================================================ #

REPOS="$HOME/dev_projects"

[[ "$OSTYPE" == darwin* ]] && export CPATH=$(xcrun --show-sdk-path)/usr/include

function run() {
  # requires "ntl" node package installed globally
  echo "\n"
  ntl --info --size 20
}

# ============================================================================ #
# MINIFY
# ============================================================================ #

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

# ============================================================================ #
# REPO DEPLOY
# ============================================================================ #

# DEPLOYMENT FOR A STATIC/REACT BUILD TO A REMOTE WEBROOT
# RUN FROM REPO ROOT. Host details come from .env — see .env.example.
function deploy-static() {
  if [[ -z "${DEPLOY_SSH_TARGET:-}" || -z "${DEPLOY_SITE:-}" ]]; then
    print "deploy-static: set DEPLOY_SSH_TARGET, DEPLOY_SITE (and optionally" >&2
    print "  DEPLOY_SSH_PORT, DEPLOY_REMOTE_ROOT) in .env" >&2
    return 1
  fi

  cross-env GENERATE_SOURCEMAP=false react-scripts build || return 1
  mv build "$DEPLOY_SITE" || return 1
  rsync -avru --delete-before -e "ssh -p ${DEPLOY_SSH_PORT:-22}" \
    "./${DEPLOY_SITE}" "${DEPLOY_SSH_TARGET}:${DEPLOY_REMOTE_ROOT:-/var/www}"
  rm -rf "$DEPLOY_SITE"
}

# ============================================================================ #
# DEV + TESTING
# ============================================================================ #

# CRONIC CRON ;)
function cx() {
  pm2 stop cronic
  pm2 delete cronic
  cd $REPOS/cronic
  rm log/access.log
  rm log/error.log
  pm2 start
  pm2 log cronic
}

# ============================================================================ #
# GO LANG
# ============================================================================ #

export GO111MODULE=on

# ============================================================================ #
# LOGS
# ============================================================================ #

function lg() {
  if [[ $1 > "" ]]; then
    sudo multitail -n 500 $1
  else
    sudo lnav /var/log/syslog
  fi
}

alias logs-aa="sudo lnav /var/log/apache2/access.log"
alias logs-ae="sudo lnav /var/log/apache2/error.log"

function tailc() {
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

# list new/recent logs (1 DAY)
function logsr() {
  VAR_SINCE=0.5
  sudo find /var/log -mtime -$VAR_SINCE -ls
}

# ============================================================================ #
# PM2
# ============================================================================ #

function pm2da() {
  pm2 delete all
}

function pm2ll() {
  pm2 list --sort id:asc
}
