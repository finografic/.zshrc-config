import { describe, expect, it } from 'vitest';

import {
  MAX_SUBJECT_LENGTH,
  buildPrompt,
  cleanResponse,
  enforceHeaderShape,
  hasConventionalType,
  normalizeScope,
  selectModel,
} from './commitMessage.js';

describe('buildPrompt', () => {
  it('includes the file list and diff', () => {
    const prompt = buildPrompt({ files: ['lib/git.zsh'], diff: '+ added a line' });
    expect(prompt).toContain('lib/git.zsh');
    expect(prompt).toContain('+ added a line');
  });

  it('lists the allowed commit types', () => {
    expect(buildPrompt({ files: [], diff: '' })).toContain('feat, fix');
  });

  it('truncates an oversized diff rather than sending it whole', () => {
    const hugeDiff = 'x'.repeat(20000);
    const prompt = buildPrompt({ files: [], diff: hugeDiff });
    expect(prompt.length).toBeLessThan(hugeDiff.length);
    expect(prompt).toContain('truncated');
  });

  it('leaves a small diff untouched', () => {
    const prompt = buildPrompt({ files: [], diff: 'short diff' });
    expect(prompt).toContain('short diff');
    expect(prompt).not.toContain('truncated');
  });
});

describe('cleanResponse', () => {
  it('passes through a clean single line', () => {
    expect(cleanResponse('fix(git): stop clobbering the bold color var')).toBe(
      'fix(git): stop clobbering the bold color var',
    );
  });

  it('strips wrapping backticks', () => {
    expect(cleanResponse('`feat: add a thing`')).toBe('feat: add a thing');
  });

  it('strips a markdown code fence', () => {
    expect(cleanResponse('```\nfeat: add a thing\n```')).toBe('feat: add a thing');
  });

  it('strips wrapping quotes', () => {
    expect(cleanResponse('"feat: add a thing"')).toBe('feat: add a thing');
  });

  it('strips a leading "Commit message:" echo', () => {
    expect(cleanResponse('Commit message: feat: add a thing')).toBe('feat: add a thing');
  });

  it('takes the first non-empty line when the model rambles', () => {
    const raw = '\n\nfeat: add a thing\n\nThis adds a thing because...';
    expect(cleanResponse(raw)).toBe('feat: add a thing');
  });

  it('truncates the subject to the commitlint subject limit', () => {
    const long = `feat: ${'a'.repeat(200)}`;
    const result = cleanResponse(long);
    expect(result).toBe(`feat: ${'a'.repeat(MAX_SUBJECT_LENGTH)}`);
  });

  it('truncates at a word boundary rather than mid-word', () => {
    const long = `feat: ${'word '.repeat(40)}`.trim();
    const result = cleanResponse(long);
    expect(result.endsWith('word')).toBe(true);
    expect(result.replace(/^feat: /, '').length).toBeLessThanOrEqual(MAX_SUBJECT_LENGTH);
  });

  it('returns an empty string for genuinely empty output', () => {
    expect(cleanResponse('   \n  \n')).toBe('');
  });

  it('repairs a bare scope with no type (the real "(build):" failure)', () => {
    expect(cleanResponse('(build): update sidebar width breakpoints for wide layout')).toBe(
      'build: update sidebar width breakpoints for wide layout',
    );
  });

  it('lowercases and single-words a CamelCase scope (the real "(VaultBrowser)" failure)', () => {
    expect(cleanResponse('feat(VaultBrowser): add support for wide view mode')).toBe(
      'feat(vault): add support for wide view mode',
    );
  });
});

describe('normalizeScope', () => {
  it('lowercases', () => {
    expect(normalizeScope('Git')).toBe('git');
  });

  it('keeps only the first of several comma-separated scopes', () => {
    expect(normalizeScope('api, client')).toBe('api');
  });

  it('keeps only the first of several slash-separated scopes', () => {
    expect(normalizeScope('lib/git')).toBe('lib');
  });

  it('takes the first word of a CamelCase name', () => {
    expect(normalizeScope('VaultBrowser')).toBe('vault');
  });

  it('leaves a hyphenated single word intact', () => {
    expect(normalizeScope('nvm-autoload')).toBe('nvm-autoload');
  });

  it('does not split an all-caps acronym', () => {
    expect(normalizeScope('API')).toBe('api');
  });

  it('returns empty for an empty or unusable scope', () => {
    expect(normalizeScope('')).toBe('');
    expect(normalizeScope('!!!')).toBe('');
  });
});

describe('enforceHeaderShape', () => {
  it('leaves an already-valid header alone', () => {
    expect(enforceHeaderShape('fix(git): stop clobbering the bold color var')).toBe(
      'fix(git): stop clobbering the bold color var',
    );
  });

  it('promotes a type written inside the parens', () => {
    expect(enforceHeaderShape('(build): update breakpoints')).toBe('build: update breakpoints');
  });

  it('adds a chore type when only a real scope was given', () => {
    expect(enforceHeaderShape('(sidebar): update breakpoints')).toBe('chore(sidebar): update breakpoints');
  });

  it('maps a near-miss type name onto a real one', () => {
    expect(enforceHeaderShape('feature: add a thing')).toBe('feat: add a thing');
    expect(enforceHeaderShape('bugfix(git): stop the clobber')).toBe('fix(git): stop the clobber');
  });

  it('falls back to chore for an unrecognised type', () => {
    expect(enforceHeaderShape('update(sidebar): change widths')).toBe('chore(sidebar): change widths');
  });

  it('lowercases the type', () => {
    expect(enforceHeaderShape('Feat: add a thing')).toBe('feat: add a thing');
  });

  it('preserves a breaking-change marker', () => {
    expect(enforceHeaderShape('refactor!: drop the spinner')).toBe('refactor!: drop the spinner');
    expect(enforceHeaderShape('feat(Api)!: change the CLI')).toBe('feat(api)!: change the CLI');
  });

  it('strips a trailing period from the subject', () => {
    expect(enforceHeaderShape('feat: add a thing.')).toBe('feat: add a thing');
  });

  it('leaves a message with no colon untouched for zu-normalize-message to prefix', () => {
    expect(enforceHeaderShape('tidy up aliases')).toBe('tidy up aliases');
  });

  it('leaves a header with an empty subject untouched rather than emitting a bare type', () => {
    expect(enforceHeaderShape('feat(git):')).toBe('feat(git):');
  });

  it('collapses a doubled header, keeping the first', () => {
    expect(enforceHeaderShape('feat(core): refactor(parse): improve the handling')).toBe(
      'feat(core): improve the handling',
    );
  });

  it('collapses a tripled header', () => {
    expect(enforceHeaderShape('feat(core): refactor: fix(parse): improve the handling')).toBe(
      'feat(core): improve the handling',
    );
  });

  it('leaves an ordinary subject containing a colon alone', () => {
    expect(enforceHeaderShape('feat(git): add support for one thing: the other')).toBe(
      'feat(git): add support for one thing: the other',
    );
  });
});

describe('hasConventionalType', () => {
  it('recognises a plain type', () => {
    expect(hasConventionalType('chore: tidy up')).toBe(true);
  });

  it('recognises a scoped type', () => {
    expect(hasConventionalType('fix(git): stop clobbering')).toBe(true);
  });

  it('recognises a breaking-change marker', () => {
    expect(hasConventionalType('feat!: change the CLI')).toBe(true);
  });

  it('rejects a message with no type', () => {
    expect(hasConventionalType('tidy up the aliases')).toBe(false);
  });

  it('rejects an unknown type', () => {
    expect(hasConventionalType('wip: still working')).toBe(false);
  });
});

describe('selectModel', () => {
  it('prefers the configured model when installed', () => {
    const installed = ['llama3.2:3b', 'gemma4:e4b-it-qat'];
    expect(selectModel(installed, 'gemma4:e4b-it-qat')).toBe('gemma4:e4b-it-qat');
  });

  it('falls back to the preference list when the configured model is missing', () => {
    const installed = ['some-other-model', 'llama3.2:3b'];
    expect(selectModel(installed, 'gemma4:e4b-it-qat')).toBe('llama3.2:3b');
  });

  it('falls back further down the preference list', () => {
    const installed = ['gemma4:12b-mlx'];
    expect(selectModel(installed, undefined)).toBe('gemma4:12b-mlx');
  });

  it('falls back to the first installed model when nothing preferred is available', () => {
    const installed = ['totally-unknown-model'];
    expect(selectModel(installed, undefined)).toBe('totally-unknown-model');
  });

  it('returns null when nothing is installed', () => {
    expect(selectModel([], undefined)).toBeNull();
  });

  it('respects a custom fallback order', () => {
    const installed = ['b', 'a'];
    expect(selectModel(installed, undefined, ['a', 'b'])).toBe('a');
  });
});
