import { describe, expect, it } from 'vitest';

import { buildGeneratePayload, resolveOllamaKeepAlive } from './ollama.js';

describe('resolveOllamaKeepAlive', () => {
  it('passes through a configured duration', () => {
    expect(resolveOllamaKeepAlive('30m')).toBe('30m');
  });

  it('trims whitespace', () => {
    expect(resolveOllamaKeepAlive(' 1h ')).toBe('1h');
  });

  it('omits empty values', () => {
    expect(resolveOllamaKeepAlive('')).toBeUndefined();
    expect(resolveOllamaKeepAlive('   ')).toBeUndefined();
    expect(resolveOllamaKeepAlive(undefined)).toBeUndefined();
  });
});

describe('buildGeneratePayload', () => {
  it('includes keep_alive when configured', () => {
    expect(buildGeneratePayload('gemma4:e4b-it-qat', 'diff', '30m')).toEqual({
      model: 'gemma4:e4b-it-qat',
      prompt: 'diff',
      stream: false,
      keep_alive: '30m',
    });
  });

  it('does not send keep_alive when unset', () => {
    expect(buildGeneratePayload('gemma4:e4b-it-qat', 'diff', undefined)).toEqual({
      model: 'gemma4:e4b-it-qat',
      prompt: 'diff',
      stream: false,
    });
  });
});
