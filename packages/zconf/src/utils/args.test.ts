import { describe, expect, it } from 'vitest';

import { numberOption, parseArgs, stringOption } from './args.js';

describe('parseArgs', () => {
  it('takes the first positional as the command', () => {
    expect(parseArgs(['doctor']).command).toBe('doctor');
  });

  it('defaults to help with no arguments', () => {
    expect(parseArgs([]).command).toBe('help');
  });

  it('collects boolean flags', () => {
    expect(parseArgs(['doctor', '--strict']).flags.has('--strict')).toBe(true);
  });

  it('reads --key=value', () => {
    expect(parseArgs(['graph', '--profile=codex']).options.get('--profile')).toBe('codex');
  });

  it('reads --key value for known value flags', () => {
    expect(parseArgs(['graph', '--profile', 'codex']).options.get('--profile')).toBe('codex');
  });

  it('does not swallow the next flag as a value', () => {
    const args = parseArgs(['bench', '--profile', '--strict']);
    expect(args.flags.has('--profile')).toBe(true);
    expect(args.flags.has('--strict')).toBe(true);
  });

  it('keeps extra positionals in order', () => {
    expect(parseArgs(['new-profile', 'work-linux']).positionals).toEqual(['work-linux']);
  });

  it('does not treat a value as a positional', () => {
    // Regression guard: `--zenv codex` must not make `codex` look like a name.
    expect(parseArgs(['bench', '--zenv', 'codex']).positionals).toEqual([]);
  });
});

describe('numberOption', () => {
  it('reads the first matching name', () => {
    expect(numberOption(parseArgs(['bench', '-n', '25']), ['-n', '--runs'], 10)).toBe(25);
  });

  it('falls back when absent', () => {
    expect(numberOption(parseArgs(['bench']), ['-n'], 10)).toBe(10);
  });

  it('falls back when the value is not a number', () => {
    expect(numberOption(parseArgs(['bench', '-n=abc']), ['-n'], 10)).toBe(10);
  });

  it('accepts a fractional threshold', () => {
    expect(numberOption(parseArgs(['bench', '--threshold=0.15']), ['--threshold'], 0.2)).toBe(0.15);
  });
});

describe('stringOption', () => {
  it('accepts either alias', () => {
    const args = parseArgs(['graph', '--zenv=codex']);
    expect(stringOption(args, ['--profile', '--zenv'])).toBe('codex');
  });

  it('returns null when absent', () => {
    expect(stringOption(parseArgs(['graph']), ['--profile'])).toBeNull();
  });
});
