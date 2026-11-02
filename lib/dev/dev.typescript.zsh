# ============================================================================ #
# DEV TS USAGE - helper for tracking TypeScript file usage in a monorepo
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

# ts-usage: find where a TS/JS file (or one of its exports) is used in a monorepo.
#
# Follows:
#   - relative imports           import { X } from '../components/table'
#   - barrel re-exports          export * from './table'  (any depth)
#   - package / path-alias names import { X } from '@scope/table-common'
#
# Usage:
#   ts-usage [-s <name>] [-l] <file> [<file>...]
#     -s <name>  track one export only (e.g. a util, type or hook in the file)
#     -l         list importing files only (repo-relative, one per line)
#
# Needs: git, rg, jq

ts-usage() {
  emulate -L zsh
  setopt extended_glob

  local list_only=0 symbol=
  while (($#)); do
    case $1 in
    -l | --list) list_only=1 ;;
    -s | --symbol)
      symbol=$2
      shift
      ;;
    -h | --help)
      print "usage: ts-usage [-s <name>] [-l] <file>..."
      return 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      print -u2 "ts-usage: unknown option: $1"
      return 2
      ;;
    *) break ;;
    esac
    shift
  done
  (($#)) || {
    print -u2 "usage: ts-usage [-s <name>] [-l] <file>..."
    return 2
  }

  # Colors: off when output is piped, when NO_COLOR is set, or with -l.
  # colors.zsh stores codes as text ("\033[0m"). echo turns that into a real
  # escape code, but print -r does not. (g::) does the same job as echo, once.
  local c_title= c_dim= c_dim2= c_path= c_name= c_proj= c_warn= c_0=
  if [[ -t 1 && -z ${NO_COLOR-} ]] && ((! list_only)); then
    c_title=$(_ts_usage_color _C $'\e[1;36m')                            # bold cyan  : main title
    c_dim2=$(_ts_usage_color _d $'\e[2m')$(_ts_usage_color _c $'\e[36m') # dim cyan : labels, footer
    c_dim=$(_ts_usage_color _c $'\e[36m')                                # cyan       : labels, footer
    c_path=$(_ts_usage_color _grey $'\e[2;37m')                          # grey       : paths, line numbers
    c_name=$(_ts_usage_color _w $'\e[37m')                               # white      : imported names
    c_proj=$(_ts_usage_color _W $'\e[1;37m')                             # bold white : project headers
    c_warn=$(_ts_usage_color _y $'\e[33m')                               # yellow     : warnings, [test], [maybe]
    c_0=$(_ts_usage_color _0 $'\e[0m')                                   # reset
  fi

  local cmd
  for cmd in git rg jq; do
    (($+commands[$cmd])) || {
      _ts_usage_warn "ts-usage needs '$cmd'"
      return 1
    }
  done

  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    _ts_usage_warn "Not inside of git repository"
    return 1
  }
  root=${root:A}

  local file rc=0
  for file in "$@"; do
    _ts_usage_one "$root" "$file" "$symbol" "$list_only" || rc=1
  done
  return rc
}

# Print a colors.zsh var ($1, by name) as a real escape code.
# Falls back to $2 when colors.zsh is not loaded.
_ts_usage_color() {
  emulate -L zsh
  local v=${(P)1-}
  if [[ -n $v ]]; then print -rn -- ${(g::)v}; else print -rn -- $2; fi
}

# Warning to stderr, in the same style as the git utils.
# Uses the c_* colors set by ts-usage (zsh passes caller locals down).
_ts_usage_warn() {
  print -u2 -r -- $'\n'"${c_warn}⚠️  $1${c_0}"
  [[ -n $2 ]] && print -u2 -r -- "    ${c_path}$2${c_0}"
  print -u2
}

# Print the absolute file that a path (without or with extension) points to.
_ts_usage_resolve() {
  emulate -L zsh
  local b=$1 f
  local -a cands=($b $b.{ts,tsx,mts,cts,js,jsx,mjs,cjs} $b/index.{ts,tsx,js,jsx})
  # TS ESM style: './x.js' points to './x.ts'
  [[ $b == *.(js|jsx|mjs|cjs) ]] && cands+=(${b%.*}.{ts,tsx,mts,cts})
  for f in $cands; do
    [[ -f $f ]] && {
      print -r -- ${f:A}
      return 0
    }
  done
  return 1
}

# Nearest folder (up from a file) with package.json or project.json.
_ts_usage_project() {
  emulate -L zsh
  local d=${1:h} root=$2
  while [[ $d == $root/* ]]; do
    [[ -f $d/package.json || -f $d/project.json ]] && {
      print -r -- $d
      return 0
    }
    d=${d:h}
  done
  print -r -- $root
}

# Escape a string for use in a regex.
# Plain character checks on purpose: no glob tricks, so shell options cannot break it.
_ts_usage_re() {
  emulate -L zsh
  local metas='.+*?()|[]{}^$\' c out=
  for c in ${(s::)1}; do
    if [[ $metas == *"$c"* ]]; then out+="\\$c"; else out+=$c; fi
  done
  print -r -- $out
}

# Parse an import/export clause into "imported local" pairs (in $reply).
#   '{ a, b as c }' -> 'a a' 'b c'    'Foo, { a }' -> 'default Foo' 'a a'
#   '* as NS'       -> '* NS'         '*'          -> '* *'
_ts_usage_clause() {
  emulate -L zsh
  setopt extended_glob
  local c=$1 inside= outside item imp loc
  local lb='{' rb='}' # kept in variables so no brace sits inside ${...}
  reply=()
  c=${c%%[[:space:]]#from}
  c=${c##[[:space:]]#type[[:space:]]##}
  outside=$c
  if [[ $c == *$lb*$rb* ]]; then
    inside=${${c#*$lb}%%$rb*}
    outside="${c%%$lb*} ${c##*$rb}"
  fi
  # outside braces: a default import or '* as NS'
  for item in ${(s:,:)outside}; do
    item=${${item##[[:space:]]#}%%[[:space:]]#}
    [[ -z $item ]] && continue
    if [[ $item == (#b)\*[[:space:]]##as[[:space:]]##(*) ]]; then
      reply+=("* $match[1]")
    elif [[ $item == '*' ]]; then
      reply+=('* *')
    else
      reply+=("default $item")
    fi
  done
  # inside braces: named imports / exports
  for item in ${(s:,:)inside}; do
    item=${${item##[[:space:]]#}%%[[:space:]]#}
    item=${item##type[[:space:]]##}
    [[ -z $item ]] && continue
    if [[ $item == (#b)(*)[[:space:]]##as[[:space:]]##(*) ]]; then
      imp=$match[1] loc=$match[2]
    else
      imp=$item loc=$item
    fi
    reply+=("$imp $loc")
  done
}

_ts_usage_one() {
  emulate -L zsh
  setopt extended_glob

  local root=$1 symbol=$3 list_only=$4
  local target=${2:A}
  [[ -f $target ]] || {
    _ts_usage_warn "File not found" "$2"
    return 1
  }

  local proj
  proj=$(_ts_usage_project $target $root)

  # --- import aliases (package name + tsconfig paths) that point into the project
  local -A alias_entry
  local key val e pkgname=
  local tsbase=$root/tsconfig.base.json
  [[ -f $tsbase ]] || tsbase=$root/tsconfig.json
  if [[ -f $tsbase ]]; then
    jq -r '.compilerOptions.paths // {} | to_entries[]
           | select(.key | contains("*") | not) | "\(.key)\t\(.value[0])"' $tsbase 2>/dev/null |
      while IFS=$'\t' read -r key val; do
        e=$(_ts_usage_resolve $root/${val#./}) || continue
        [[ $e == $proj/* ]] && alias_entry[$key]=$e
      done
  fi
  [[ -f $proj/package.json ]] && pkgname=$(jq -r '.name // empty' $proj/package.json 2>/dev/null)
  if [[ -n $pkgname && -z ${alias_entry[$pkgname]} ]]; then
    e=$(_ts_usage_resolve $proj/src/index || _ts_usage_resolve $proj/index) && alias_entry[$pkgname]=$e
  fi

  # --- names the target exports
  local -a own
  own=(${(f)"$(rg -o --no-filename -r '$1' \
    '^\s*export\s+(?:declare\s+)?(?:default\s+)?(?:abstract\s+)?(?:async\s+)?(?:function\*?|const|let|var|class|type|interface|enum)\s+([A-Za-z_$][\w$]*)' \
    $target 2>/dev/null)"})
  local line exlist
  local re_exlist='export\s+(?:type\s+)?\{([^}]*)\}([^;\n]*)'
  exlist=$(rg -U -o --no-filename -r '$1|$2' $re_exlist $target 2>/dev/null)
  for line in ${(f)exlist}; do
    [[ ${line#*|} == *from* ]] && continue
    _ts_usage_clause "{${line%%|*}}"
    for e in $reply; do own+=(${e#* }); done
  done
  rg -q '^\s*export\s+default\b' $target 2>/dev/null && own+=(default)
  own=(${(u)own})

  if [[ -n $symbol && ${own[(Ie)$symbol]} -eq 0 ]]; then
    _ts_usage_warn "'$symbol' is not exported by ${target#$root/}" "exports: ${(j:, :)own:-none found}"
    return 1
  fi

  # --- walk: find importers, add barrels to the chain, repeat until stable
  local -A chain names_at importers
  chain[$target]=1
  names_at[$target]=${symbol:-${(j: :)own}}

  local -a stems aliases
  for key in ${(k)alias_entry}; do aliases+=($(_ts_usage_re $key)); done

  local jqprog='
    select(.type == "match") | .data as $d | $d.submatches[]
    | ($d.line_number + ([$d.lines.text[0:.start] | match("\n"; "g")] | length)) as $ln
    | .match.text | gsub("\\s+"; " ")
    | capture("^(?<kw>\\w+)(?<clause>[^\"\\x27]*)[\"\\x27](?<spec>[^\"\\x27]+)[\"\\x27]$")
    | [$d.path.text, ($ln | tostring), .kw, .spec, (.clause | gsub("^ +| +$"; ""))] | @tsv'

  local changed=1 f s stem pat specpat file ln kw spec clause resolved sub
  local -a hit passed have
  while ((changed)); do
    changed=0
    importers=()

    stems=()
    for f in ${(k)chain}; do
      stem=${f:t:r}
      [[ $stem == index ]] && stem=${f:h:t}
      stems+=($(_ts_usage_re $stem))
    done
    stems=(${(u)stems})
    if ((${#${(M)stems:#}} || ${#${(M)aliases:#}})); then
      _ts_usage_warn "Could not build the search pattern (empty name). Stopping."
      return 1
    fi
    ((${+TS_USAGE_DEBUG})) && print -u2 "ts-usage: stems=[$stems] aliases=[$aliases]"

    specpat="\\.{1,2}/(?:[^'\"\\n]*/)?(?:${(j:|:)stems})(?:\\.[cm]?[jt]sx?)?"
    (($#aliases)) && specpat+="|(?:${(j:|:)aliases})(?:/[^'\"\\n]*)?"
    pat="\\b(?:import|export|require|mock)\\b[^;'\"]*?['\"](?:$specpat)['\"]"

    rg --json -U -g '*.{ts,tsx,mts,cts,js,jsx,mjs,cjs}' -e "$pat" $root 2>/dev/null |
      jq -r $jqprog 2>/dev/null |
      while IFS=$'\t' read -r file ln kw spec clause; do
        file=${file:A}
        [[ $file == $target ]] && continue

        # resolve the specifier to a file
        resolved=
        if [[ $spec == .* ]]; then
          resolved=$(_ts_usage_resolve ${file:h}/$spec)
        else
          for key in ${(k)alias_entry}; do
            if [[ $spec == $key ]]; then
              resolved=$alias_entry[$key]
              break
            elif [[ $spec == $key/* ]]; then
              sub=${spec#$key/}
              resolved=$(_ts_usage_resolve $proj/$sub || _ts_usage_resolve $proj/src/$sub)
              break
            fi
          done
        fi
        [[ -n $resolved && -n ${chain[$resolved]} ]] || continue

        have=(${=names_at[$resolved]})

        # re-export: this file is a barrel
        if [[ $kw == export && $clause == *from ]]; then
          passed=()
          _ts_usage_clause $clause
          for s in $reply; do
            if [[ ${s% *} == '*' ]]; then
              [[ ${s#* } == '*' ]] && passed+=($have) || passed+=(${s#* })
            elif ((${have[(Ie)${s% *}]})); then
              passed+=(${s#* })
            fi
          done
          (($#passed)) || continue
          [[ -z ${chain[$file]} ]] && {
            chain[$file]=1
            changed=1
          }
          for s in $passed; do
            if ((! ${${=names_at[$file]}[(Ie)$s]})); then
              names_at[$file]+=" $s"
              changed=1
            fi
          done
          continue
        fi

        # usage
        hit=()
        if [[ $kw == import && ($clause == *from || -z $clause) ]]; then
          _ts_usage_clause $clause
          for s in $reply; do
            if [[ ${s% *} == '*' ]]; then
              hit+=("* as ${s#* }")
            elif ((${have[(Ie)${s% *}]})); then
              hit+=(${s% *})
            fi
          done
          # direct import of the file (no -s): any import counts
          [[ -z $symbol && $resolved == $target && $#hit -eq 0 ]] && hit=("${clause:-side effect}")
        else
          # require / mock / dynamic import: names unknown when it goes through a barrel
          [[ $resolved == $target ]] && hit=("$kw(…)") || hit=("$kw(…)  [maybe]")
        fi
        (($#hit)) || continue
        importers[$file]+="$ln|${(j:, :)hit}"$'\n'
      done
  done

  # --- output
  local -a users=(${(ok)importers})
  if ((list_only)); then
    for f in $users; do print -r -- ${f#$root/}; done
    return 0
  fi

  # header
  local rel=${target#$root/}
  print
  print -r -- "${c_title}${rel}${c_0}${symbol:+  ${c_dim2}symbol:${c_0} ${c_name}${symbol}${c_0}}"
  [[ -n $pkgname ]] && print -r -- "  ${c_dim2}package${c_0}  ${pkgname}"
  print -r -- "  ${c_dim2}exports${c_0}  ${c_name}${names_at[$target]// /, }${c_0}"
  local -a barrels=(${(ok)chain})
  barrels=(${barrels:#$target})
  local b label="barrels"
  for b in $barrels; do
    print -r -- "  ${c_dim2}${label}${c_0}  ${c_path}${b#$root/}${c_0}"
    label="       "
  done
  print

  if ((! $#users)); then
    print -r -- "  ${c_warn}⚠️  No usage found. This code may be dead.${c_0}"
    return 0
  fi

  # body: grouped by project
  local -A by_proj
  local p ntest=0
  for f in $users; do
    p=$(_ts_usage_project $f $root)
    by_proj[$p]+="$f"$'\n'
  done

  local tag entry names
  for p in ${(ok)by_proj}; do
    local -a pf=(${(f)by_proj[$p]})
    print -r -- "  ${c_proj}${p#$root/}${c_0}  ${c_path}(${#pf})${c_0}"
    for f in $pf; do
      tag=
      if [[ ${f:t} == *.(test|spec|stories).* || $f == */__tests__/* || $f == */e2e/* ]]; then
        tag="  ${c_warn}[test]${c_0}"
        ((ntest++))
      fi
      for entry in ${(f)importers[$f]}; do
        names=${entry#*|}
        if [[ $names == *'[maybe]' ]]; then
          names="${c_name}${names%  \[maybe\]}${c_0}  ${c_warn}[maybe]${c_0}"
        else
          names="${c_name}${names}${c_0}"
        fi
        print -r -- "    ${c_path}${f#$p/}:${entry%%|*}${c_0}  ${names}${tag}"
      done
    done
    print
  done

  # footer
  local nf=${#users} np=${#by_proj}
  local summary="$nf file$( ((nf == 1)) || print s) · $np project$( ((np == 1)) || print s)"
  ((ntest)) && summary+=" · $ntest tests/stories"
  print -r -- "  ${c_dim2}${summary}${c_0}"
  return 0
}

# ============================================================================ #
# ============================================================================ #

# ts-related: for every file that imports <package>, show how it relates to <wrapper-file>.
#
#   wrapper   the wrapper file itself
#   internal  the wrapper imports it (any depth, relative imports)
#   user      it imports the wrapper (via ts-usage)
#   helper    a wrapper user imports it (any depth, relative imports)
#   separate  no link to the wrapper: its own table
#
# Usage: ts-related <wrapper-file> <package>
#   ts-related packages/libs/common/table-common/src/components/table.tsx @tanstack/react-table
#
# Needs: ts-usage (dev.typescript.zsh), git, rg

ts-related() {
  emulate -L zsh
  setopt extended_glob

  (($# == 2)) || {
    print -u2 "usage: ts-related <wrapper-file> <package>"
    return 2
  }
  # Plain command form on purpose: formatters (shfmt) add spaces inside (( ))
  # and [ ] subscripts, which turns ts-usage into "ts - usage".
  typeset -f ts-usage >/dev/null 2>&1 || {
    print -u2 "ts-related: needs ts-usage (source dev.typescript.zsh)"
    return 1
  }

  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 "ts-related: run inside a git repo"
    return 1
  }
  root=${root:A}
  local wrapper=${1:A} pkg=$2
  [[ -f $wrapper ]] || {
    print -u2 "ts-related: no such file: $1"
    return 1
  }

  # wrapper users
  local -A users
  local f abs out
  out=$(ts-usage -l $wrapper)
  for f in ${(f)out}; do
    abs="$root/$f" # build the key first: shfmt adds spaces around / inside [ ]
    users[$abs]=1
  done

  # files reached by relative imports
  local -A internal helper
  out=$(_ts_related_walk $wrapper)
  for f in ${(f)out}; do internal[$f]=1; done
  out=$(_ts_related_walk ${(k)users})
  for f in ${(f)out}; do helper[$f]=1; done

  # every file that imports the package
  local re_pkg="from\\s*['\"]$(_ts_usage_re $pkg)['\"]"
  local -a files
  local glob='*.{ts,tsx,mts,cts,js,jsx,mjs,cjs}'
  out=$(rg -l -g $glob -e $re_pkg $root 2>/dev/null)
  files=(${(f)out})
  files=(${(o)files})

  local -A group
  local kind
  for f in $files; do
    f=${f:A}
    if [[ $f == $wrapper ]]; then
      kind=wrapper
    elif [[ -n ${internal[$f]} ]]; then
      kind=internal
    elif [[ -n ${users[$f]} ]]; then
      kind=user
    elif [[ -n ${helper[$f]} ]]; then
      kind=helper
    else
      kind=separate
    fi
    group[$kind]+="${f#$root/}"$'\n'
  done

  local -A why=(
    wrapper 'the wrapper itself'
    internal 'the wrapper imports it'
    user 'imports the wrapper'
    helper 'a wrapper user imports it'
    separate 'no link to the wrapper'
  )
  local -a list
  print
  print -r -- "${#files} files import $pkg"
  for kind in wrapper internal user helper separate; do
    list=(${(f)group[$kind]})
    (($#list)) || continue
    print
    print -r -- "$kind  (${#list})  ${why[$kind]}"
    for f in $list; do print -r -- "  $f"; done
  done
  print
}

# Print every file reached from the given files by relative imports (any depth).
_ts_related_walk() {
  emulate -L zsh
  local -A seen
  local -a queue=($@)
  local f spec r out
  local re='(?:from|import)\s*[(]?\s*[\x27"](\.[^\x27"]+)[\x27"]'
  while (($#queue)); do
    f=$queue[1]
    shift queue
    out=$(rg -o --no-filename -r '$1' -e $re $f 2>/dev/null)
    for spec in ${(f)out}; do
      r=$(_ts_usage_resolve ${f:h}/$spec) || continue
      [[ $r == *.(ts|tsx|mts|cts|js|jsx|mjs|cjs) ]] || continue
      [[ -n ${seen[$r]} ]] && continue
      seen[$r]=1
      queue+=($r)
      print -r -- $r
    done
  done
}
