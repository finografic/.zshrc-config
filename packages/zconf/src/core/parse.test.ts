import { describe, expect, it } from 'vitest';

import { maskExpansions, parseZsh, resolveSourceTarget, stripComment } from './parse.js';

describe('stripComment', () => {
  it('removes a trailing comment', () => {
    expect(stripComment('typeset -g _c="x" # Cyan').trim()).toBe('typeset -g _c="x"');
  });

  it('leaves a # inside a quoted string alone', () => {
    expect(stripComment('print "a # b"')).toBe('print "a # b"');
  });

  it('leaves a # that does not start a word alone', () => {
    expect(stripComment('local x=a#b')).toBe('local x=a#b');
  });

  it('treats a whole-line comment as empty', () => {
    expect(stripComment('  # just a note').trim()).toBe('');
  });
});

describe('maskExpansions', () => {
  it('blanks ${…} so its braces are not counted as structure', () => {
    expect(maskExpansions('print "${_c}x${_0}"').masked).not.toContain('{');
  });

  it('blanks $(…) command substitutions', () => {
    expect(maskExpansions('local v=$(uname -m)').masked).not.toContain('(');
  });

  it('keeps structural braces', () => {
    expect(maskExpansions('function f() {').masked).toContain('{');
  });

  it('handles nested ${${x}} without leaking a brace', () => {
    expect(maskExpansions('local v="${${NVM_BIN%/bin}##*/}"').masked).not.toContain('{');
  });

  it('reports an unterminated quote so the caller can continue the statement', () => {
    expect(maskExpansions("awk '").openQuote).toBe("'");
  });

  it('resumes inside a quote opened on a previous line', () => {
    // The braces belong to an embedded awk program, not to shell structure.
    expect(maskExpansions('  { print $1 }', "'").masked).not.toContain('{');
  });
});

describe('resolveSourceTarget', () => {
  it('strips $ZSHRC_ROOT and quotes', () => {
    expect(resolveSourceTarget('"$ZSHRC_ROOT/lib/colors.zsh"')).toBe('lib/colors.zsh');
  });

  it('strips the braced form too', () => {
    expect(resolveSourceTarget('"${ZSHRC_ROOT}/lib/git.zsh"')).toBe('lib/git.zsh');
  });

  it('returns null for a runtime-dependent target', () => {
    expect(resolveSourceTarget('"$ZENV_PATH/$ZENV.aliases.zsh"')).toBeNull();
  });
});

describe('parseZsh', () => {
  it('detects a shebang', () => {
    expect(parseZsh('#!/bin/zsh\nprint hi\n').hasShebang).toBe(true);
    expect(parseZsh('# NOTE: sourced\nprint hi\n').hasShebang).toBe(false);
  });

  it('records source statements with resolved targets', () => {
    const parsed = parseZsh('source "$ZSHRC_ROOT/lib/colors.zsh"\n');
    expect(parsed.sources).toHaveLength(1);
    expect(parsed.sources[0]?.resolved).toBe('lib/colors.zsh');
    expect(parsed.sources[0]?.inFunction).toBe(false);
  });

  it('marks a source inside a function body as such', () => {
    const parsed = parseZsh(['function f() {', '  source "$ZSHRC_ROOT/lib/x.zsh"', '}'].join('\n'));
    expect(parsed.sources[0]?.inFunction).toBe(true);
  });

  it('finds both function definition styles', () => {
    const parsed = parseZsh(['function a() {', '}', 'b() {', '}'].join('\n'));
    expect(parsed.functions.map((f) => f.name)).toEqual(['a', 'b']);
    expect(parsed.functions[0]?.usesFunctionKeyword).toBe(true);
    expect(parsed.functions[1]?.usesFunctionKeyword).toBe(false);
  });

  it('finds `function name {` without parentheses', () => {
    const parsed = parseZsh('function solo {\n}\n');
    expect(parsed.functions.map((f) => f.name)).toEqual(['solo']);
  });

  it('does not treat a function body as top level', () => {
    const parsed = parseZsh(['function f() {', '  echo inside', '}', 'echo outside'].join('\n'));
    expect(parsed.topLevel.map((s) => s.text)).toEqual(['echo outside']);
  });

  it('is not desynchronised by ${…} inside a function body', () => {
    const parsed = parseZsh(['function f() {', '  print "${_c}hello${_0}"', '}', 'echo outside'].join('\n'));
    expect(parsed.topLevel.map((s) => s.text)).toEqual(['echo outside']);
  });

  it('skips heredoc bodies', () => {
    const parsed = parseZsh(['cat << EOF', 'echo not-a-statement', 'EOF', 'echo real'].join('\n'));
    expect(parsed.topLevel.map((s) => s.text)).toEqual(['cat << EOF', 'echo real']);
  });

  it('flags top-level command substitution', () => {
    const parsed = parseZsh('export CPATH=$(xcrun --show-sdk-path)/usr/include\n');
    expect(parsed.topLevel[0]?.hasCommandSubstitution).toBe(true);
  });

  it('does not flag command substitution inside a function', () => {
    const parsed = parseZsh(['function f() {', '  local v=$(uname -m)', '}'].join('\n'));
    expect(parsed.topLevel).toHaveLength(0);
  });

  it('records the head word of a top-level statement', () => {
    const parsed = parseZsh('typeset -g _c="x"\n');
    expect(parsed.topLevel[0]?.head).toBe('typeset');
  });

  it('sees the source inside a case branch', () => {
    // Regression: `lib/paths.zsh` sources every OS paths file from a `case`
    // branch. Matching `source` only at the start of a statement missed all
    // three, which made them look like orphans.
    const parsed = parseZsh(
      [
        'case "$OS_NAME" in',
        'macOS) source "$ZSHRC_ROOT/lib/paths/paths.macos.zsh" ;;',
        'Linux) source "$ZSHRC_ROOT/lib/paths/paths.linux.zsh" ;;',
        'esac',
      ].join('\n'),
    );
    expect(parsed.sources.map((s) => s.resolved)).toEqual([
      'lib/paths/paths.macos.zsh',
      'lib/paths/paths.linux.zsh',
    ]);
  });

  it('reports the command of a case branch, not the pattern', () => {
    const parsed = parseZsh(['case "$X" in', 'macOS) print hi ;;', 'esac'].join('\n'));
    expect(parsed.topLevel.map((s) => s.head)).toContain('print');
    expect(parsed.topLevel.map((s) => s.head)).not.toContain('macOS)');
  });

  it('joins a statement continued with a trailing backslash', () => {
    // Regression: `lib/colors.zsh` ends its `typeset +x` list with a
    // continuation; the second line alone read as a bare `_GREY` command.
    const parsed = parseZsh('typeset +x _d _0 \\\n  _GREY _GRAY\n');
    expect(parsed.topLevel).toHaveLength(1);
    expect(parsed.topLevel[0]?.head).toBe('typeset');
  });

  it('does not count braces inside a multi-line quoted string', () => {
    // Regression: `lib/utils.zsh` embeds a multi-line awk program in single
    // quotes. Counting its braces desynchronised depth for the rest of the
    // file, so later function bodies looked like top-level code.
    const parsed = parseZsh(
      [
        'function ports() {',
        "  lsof -i | awk '",
        '  {',
        '    print $1',
        "  }'",
        '  tput sgr0',
        '}',
        'echo after',
      ].join('\n'),
    );
    expect(parsed.topLevel.map((s) => s.text)).toEqual(['echo after']);
  });

  it('handles a nested if/case block without losing depth', () => {
    const parsed = parseZsh(
      ['if [[ -n "$X" ]]; then', '  case "$Y" in', '  a) print a ;;', '  esac', 'fi', 'echo after'].join(
        '\n',
      ),
    );
    expect(parsed.topLevel.map((s) => s.text)).toContain('echo after');
  });
});
