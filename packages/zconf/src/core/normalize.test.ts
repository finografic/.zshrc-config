import { describe, expect, it } from 'vitest';

import {
  CANONICAL_SEPARATOR,
  applyRenames,
  buildRenames,
  collectFunctionNames,
  extractInlineTitle,
  isSectionTitleLine,
  isSeparatorLine,
  normalizeCommentBlocks,
  normalizeFunctions,
  shouldSkipForNormalize,
  toKebab,
} from './normalize.js';

describe('isSeparatorLine', () => {
  it('recognises the canonical boxed rule', () => {
    expect(isSeparatorLine(CANONICAL_SEPARATOR)).toBe(true);
  });

  it('recognises dashed and short rules', () => {
    expect(isSeparatorLine('# -------------')).toBe(true);
    expect(isSeparatorLine('# ==== #')).toBe(true);
  });

  it('rejects prose and mixed rules', () => {
    expect(isSeparatorLine('# NOTE: a title')).toBe(false);
    expect(isSeparatorLine('# =-=-=')).toBe(false);
    expect(isSeparatorLine('not a comment')).toBe(false);
  });
});

describe('isSectionTitleLine', () => {
  it('treats a NOTE: line as a title', () => {
    expect(isSectionTitleLine('# NOTE: GIT UTILITIES')).toBe(true);
  });

  it('treats prose continuations as body, not titles', () => {
    expect(isSectionTitleLine('# This file does a thing')).toBe(false);
    expect(isSectionTitleLine('# Usage: thing --flag')).toBe(false);
  });

  it('rejects bullet lines', () => {
    expect(isSectionTitleLine('# - a bullet')).toBe(false);
  });
});

describe('extractInlineTitle', () => {
  it('pulls the title out of a trailing-equals heading', () => {
    expect(extractInlineTitle('# COLORS =========')).toBe('COLORS');
  });

  it('returns null when there is no trailing rule', () => {
    expect(extractInlineTitle('# COLORS')).toBeNull();
  });
});

describe('normalizeCommentBlocks', () => {
  it('rewrites a three-line block to canonical form', () => {
    const input = ['# =====', '# NOTE: THING', '# =====', 'code'].join('\n');
    expect(normalizeCommentBlocks(input)).toBe(
      [CANONICAL_SEPARATOR, '# NOTE: THING', CANONICAL_SEPARATOR, '', 'code'].join('\n'),
    );
  });

  it('rewrites a hash block', () => {
    const input = ['####', '#  THING  #', '####', 'code'].join('\n');
    expect(normalizeCommentBlocks(input)).toBe(
      [CANONICAL_SEPARATOR, '# THING', CANONICAL_SEPARATOR, '', 'code'].join('\n'),
    );
  });

  it('expands an inline trailing-equals heading into a block', () => {
    expect(normalizeCommentBlocks('# COLORS ====\ncode')).toBe(
      [CANONICAL_SEPARATOR, '# COLORS', CANONICAL_SEPARATOR, '', 'code'].join('\n'),
    );
  });

  it('preserves the body of a multi-line block', () => {
    // The bug this guards is the reason the Python original could not be run:
    // it injected a closing rule straight after the title and pushed the prose
    // out of the block, mangling 28 files.
    const input = ['# =====', '# NOTE: THING', '# explanatory prose', '# more prose', '# =====', 'code'].join(
      '\n',
    );

    expect(normalizeCommentBlocks(input)).toBe(
      [
        CANONICAL_SEPARATOR,
        '# NOTE: THING',
        '# explanatory prose',
        '# more prose',
        CANONICAL_SEPARATOR,
        '',
        'code',
      ].join('\n'),
    );
  });

  it('does not invent a closing rule for an unclosed separator', () => {
    // Guessing where an unclosed block ends is what caused the damage.
    expect(normalizeCommentBlocks('# ====\n# NOTE: THING\ncode')).toBe(
      [CANONICAL_SEPARATOR, '# NOTE: THING', 'code'].join('\n'),
    );
  });

  it('does not merge two blocks separated by code', () => {
    const input = ['# ====', '# A', '# ====', 'code', '# ====', '# B', '# ===='].join('\n');
    const out = normalizeCommentBlocks(input);
    expect(out.split('\n').filter((l) => l === CANONICAL_SEPARATOR)).toHaveLength(4);
  });

  it('normalises a lone separator without inventing a title', () => {
    expect(normalizeCommentBlocks('# ----\ncode')).toBe([CANONICAL_SEPARATOR, 'code'].join('\n'));
  });

  it('leaves already-canonical content untouched', () => {
    const input = [CANONICAL_SEPARATOR, '# NOTE: THING', CANONICAL_SEPARATOR, '', 'code', ''].join('\n');
    expect(normalizeCommentBlocks(input)).toBe(input);
  });

  it('preserves a trailing newline', () => {
    expect(normalizeCommentBlocks('code\n').endsWith('\n')).toBe(true);
    expect(normalizeCommentBlocks('code')).toBe('code');
  });

  it('does not add a blank line before an already-blank line', () => {
    const input = ['# ====', '# NOTE: T', '# ====', '', 'code'].join('\n');
    expect(normalizeCommentBlocks(input)).toBe(
      [CANONICAL_SEPARATOR, '# NOTE: T', CANONICAL_SEPARATOR, '', 'code'].join('\n'),
    );
  });

  it('is idempotent', () => {
    const input = ['# =====', '# NOTE: THING', '# =====', 'code'].join('\n');
    const once = normalizeCommentBlocks(input);
    expect(normalizeCommentBlocks(once)).toBe(once);
  });
});

describe('toKebab', () => {
  it('converts snake_case', () => {
    expect(toKebab('my_thing_here')).toBe('my-thing-here');
  });

  it('preserves a leading underscore prefix', () => {
    expect(toKebab('_my_thing')).toBe('_my-thing');
  });

  it('leaves a name with no underscore alone', () => {
    expect(toKebab('already-kebab')).toBe('already-kebab');
    expect(toKebab('_gb')).toBe('_gb');
  });
});

describe('collectFunctionNames / buildRenames', () => {
  it('finds both definition styles', () => {
    const names = collectFunctionNames(['function a_b() {\n}\nc_d() {\n}\n']);
    expect([...names].sort()).toEqual(['a_b', 'c_d']);
  });

  it('proposes renames only for snake_case', () => {
    const renames = buildRenames(['a_b', 'already-fine']);
    expect([...renames.entries()]).toEqual([['a_b', 'a-b']]);
  });

  it('never renames a protected zsh hook', () => {
    expect(buildRenames(['precmd', 'chpwd']).size).toBe(0);
  });
});

describe('normalizeFunctions', () => {
  it('adds the function keyword', () => {
    expect(normalizeFunctions('thing() {\n}\n', new Map())).toBe('function thing() {\n}\n');
  });

  it('keeps one space before the brace', () => {
    // Deliberate deviation from the Python original, which emitted
    // `function thing(){` and would have restyled every definition in the repo.
    expect(normalizeFunctions('thing()   {\n}\n', new Map())).toBe('function thing() {\n}\n');
    expect(normalizeFunctions('function thing(){\n}\n', new Map())).toBe('function thing() {\n}\n');
  });

  it('renames a definition and its call sites together', () => {
    const renames = new Map([['my_thing', 'my-thing']]);
    const input = 'my_thing() {\n  :\n}\nmy_thing arg\n';
    expect(normalizeFunctions(input, renames)).toBe('function my-thing() {\n  :\n}\nmy-thing arg\n');
  });

  it('does not substitute a short name inside a longer one', () => {
    const renames = new Map([
      ['a_b', 'a-b'],
      ['a_b_c', 'a-b-c'],
    ]);
    expect(applyRenames('a_b_c and a_b', renames)).toBe('a-b-c and a-b');
  });

  it('leaves an unrelated identifier alone', () => {
    const renames = new Map([['run', 'run']]);
    expect(applyRenames('prerun runner', renames)).toBe('prerun runner');
  });

  it('adds the keyword to a protected hook without renaming it', () => {
    expect(normalizeFunctions('precmd() {\n}\n', buildRenames(['precmd']))).toBe('function precmd() {\n}\n');
  });

  it('is idempotent', () => {
    const renames = new Map([['my_thing', 'my-thing']]);
    const once = normalizeFunctions('my_thing() {\n}\n', renames);
    expect(normalizeFunctions(once, renames)).toBe(once);
  });
});

describe('shouldSkipForNormalize', () => {
  it('skips vendored and generated paths', () => {
    expect(shouldSkipForNormalize('vendor/nvm.zsh')).toBe(true);
    expect(shouldSkipForNormalize('scripts/.iterm2_shell_integration.zsh')).toBe(true);
    expect(shouldSkipForNormalize('themes/p10k/$HOME.cache/x.zsh')).toBe(true);
    expect(shouldSkipForNormalize('node_modules/a/b.zsh')).toBe(true);
  });

  it('does not skip ordinary modules', () => {
    expect(shouldSkipForNormalize('lib/git/git.core.zsh')).toBe(false);
  });
});
