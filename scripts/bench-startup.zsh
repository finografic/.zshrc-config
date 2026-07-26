#!/bin/zsh
# ============================================================================ #
# NOTE: BENCH-STARTUP - cold interactive-shell startup benchmark
#
# Usage:
#   scripts/bench-startup.zsh [-n N] [--zenv <profile>] [--all-profiles] [--save]
#
#   -n N            number of cold runs (default 20)
#   --zenv NAME     force a specific profile via ZENV_FORCE (default: whatever
#                   this machine resolves to)
#   --all-profiles  benchmark every profile in one pass
#   --save          write results to docs/benchmarks/baseline.json
#   --json          print machine-readable JSON instead of a table
#
# Reports min/p50/p95 wall-clock time for `zsh -i -c exit`, i.e. the full
# interactive load path (bootstrap -> main.zsh -> profile -> splash) with no
# work done beyond that.
# ============================================================================ #

zmodload zsh/datetime

ZSHRC_ROOT="${ZSHRC_ROOT:-${0:A:h:h}}"
RUNS=20
ZENV_TARGET=""
ALL_PROFILES=false
SAVE=false
AS_JSON=false

typeset -a ALL_PROFILE_NAMES
ALL_PROFILE_NAMES=(home-macos office-macos home-linux server-linux docker-dev vscode codex android)

while (( $# )); do
  case "$1" in
  -n)
    RUNS="$2"
    shift 2
    ;;
  --zenv)
    ZENV_TARGET="$2"
    shift 2
    ;;
  --all-profiles)
    ALL_PROFILES=true
    shift
    ;;
  --save)
    SAVE=true
    shift
    ;;
  --json)
    AS_JSON=true
    shift
    ;;
  -h | --help)
    print "Usage: bench-startup.zsh [-n N] [--zenv <profile>] [--all-profiles] [--save] [--json]"
    return 0 2>/dev/null || exit 0
    ;;
  *)
    print "bench-startup: unknown option '$1' (try --help)" >&2
    return 1 2>/dev/null || exit 1
    ;;
  esac
done

# Runs N cold shells for one profile ("" = whatever this machine resolves to),
# prints min/p50/p95 in milliseconds as three space-separated numbers.
#
# NOTE: vscode and codex are NOT reached via ZENV_FORCE alone. main.zsh's
# early exits call is-agent-shell/is-ide-shell (core/detect.zsh) directly,
# which test real env signals (TERM_PROGRAM, IS_CODEX, ...), not $ZENV — so
# ZENV_FORCE=vscode resolves the profile but skips the fast-path entirely,
# understating exactly the profiles that most need to be fast. Likewise
# docker-dev's antidote/plugin skip is gated on is-container(), not $ZENV.
# This function sets the real trigger for each, so the benchmark exercises
# the same code path a real shell of that kind would.
function bench-one-profile() {
  local zenv="$1" n="$2"
  local -a samples env_prefix
  local start end elapsed_ms i

  case "$zenv" in
  vscode) env_prefix=(TERM_PROGRAM=vscode) ;;
  codex) env_prefix=(IS_CODEX=true) ;;
  docker-dev) env_prefix=(IN_DOCKER=1 DOCKER_CONTAINER=1) ;;
  "") env_prefix=() ;;
  *) env_prefix=(ZENV_FORCE="$zenv") ;;
  esac

  for (( i = 1; i <= n; i++ )); do
    start=$EPOCHREALTIME
    env "${env_prefix[@]}" zsh -i -c exit >/dev/null 2>&1
    end=$EPOCHREALTIME
    elapsed_ms=$(( (end - start) * 1000 ))
    samples+=("$elapsed_ms")
  done

  # Sort numerically for percentiles.
  samples=(${(on)samples})

  local min p50 p95
  min="${samples[1]}"
  p50="${samples[$(( (n + 1) / 2 ))]}"
  p95="${samples[$(( n - (n * 5 / 100) ))]}"
  [[ -z "$p95" ]] && p95="${samples[-1]}"

  printf "%.1f %.1f %.1f\n" "$min" "$p50" "$p95"
}

# Splits one "profile|min|p50|p95" row into the four PROFILE/MIN/P50/P95
# globals below. A single shared parser, called from three call sites, so the
# field-splitting logic exists in exactly one place.
typeset -g PROFILE MIN P50 P95
function parse-row() {
  local row="$1" rest
  PROFILE="${row%%|*}"
  rest="${row#*|}"
  MIN="${rest%%|*}"; rest="${rest#*|}"
  P50="${rest%%|*}"; P95="${rest#*|}"
}

# Renders all rows as JSON object entries (no surrounding braces), one per
# line, comma-separated. Written into a variable rather than via `local` +
# bare re-declaration inside a redirected block — that combination is a real
# zsh footgun: `local name` with no `=` on an ALREADY-local name from an outer
# scope switches into typeset's display mode and PRINTS "name=value" to
# stdout instead of declaring anything, which silently corrupted this script's
# very first --save output straight into the JSON file.
function render-json-entries() {
  local -a out_rows=("$@")
  local -i i=0
  local comma row
  local -a lines
  for row in "${out_rows[@]}"; do
    parse-row "$row"
    (( i++ ))
    comma=","
    (( i == ${#out_rows} )) && comma=""
    lines+=("    \"$PROFILE\": { \"min_ms\": $MIN, \"p50_ms\": $P50, \"p95_ms\": $P95 }$comma")
  done
  print -l -- "${lines[@]}"
}

function run-benchmarks() {
  local -a targets
  if [[ "$ALL_PROFILES" == true ]]; then
    targets=($ALL_PROFILE_NAMES)
  elif [[ -n "$ZENV_TARGET" ]]; then
    targets=("$ZENV_TARGET")
  else
    targets=("")
  fi

  local zenv result_min result_p50 result_p95
  local -a result_parts rows

  for zenv in "${targets[@]}"; do
    result_parts=(${=$(bench-one-profile "$zenv" "$RUNS")})
    result_min="${result_parts[1]}"
    result_p50="${result_parts[2]}"
    result_p95="${result_parts[3]}"
    rows+=("${zenv:-<default>}|$result_min|$result_p50|$result_p95")
  done

  if [[ "$AS_JSON" == true ]]; then
    print '{'
    print "  \"runs\": $RUNS,"
    print "  \"profiles\": {"
    render-json-entries "${rows[@]}"
    print "  }"
    print '}'
  else
    printf "%-14s %8s %8s %8s\n" "PROFILE" "MIN(ms)" "P50(ms)" "P95(ms)"
    local row
    for row in "${rows[@]}"; do
      parse-row "$row"
      printf "%-14s %8s %8s %8s\n" "$PROFILE" "$MIN" "$P50" "$P95"
    done
  fi

  if [[ "$SAVE" == true ]]; then
    mkdir -p "$ZSHRC_ROOT/docs/benchmarks"
    local outfile="$ZSHRC_ROOT/docs/benchmarks/baseline.json"
    local json_entries
    json_entries="$(render-json-entries "${rows[@]}")"
    {
      print '{'
      print "  \"date\": \"$(date +%Y-%m-%d)\","
      print "  \"runs\": $RUNS,"
      print "  \"host\": \"$(uname -s) $(uname -m)\","
      print "  \"profiles\": {"
      print -- "$json_entries"
      print "  }"
      print '}'
    } > "$outfile"
    print "\nSaved: $outfile" >&2
  fi
}

run-benchmarks
