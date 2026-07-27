import { describe, expect, it } from 'vitest';

import {
  MAX_SUBJECT_LENGTH,
  buildPrompt,
  cleanResponse,
  hasConventionalType,
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

  it('truncates to the commitlint subject limit', () => {
    const long = `feat: ${'a'.repeat(200)}`;
    const result = cleanResponse(long);
    expect(result.length).toBe(MAX_SUBJECT_LENGTH);
  });

  it('returns an empty string for genuinely empty output', () => {
    expect(cleanResponse('   \n  \n')).toBe('');
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
