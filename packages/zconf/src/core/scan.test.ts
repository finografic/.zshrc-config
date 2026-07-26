import { describe, expect, it } from 'vitest';

import { DEFAULT_EXCLUDED_PATHS, IGNORE_MARKER, isExcluded, scanRepo, scanText } from './scan.js';

describe('scanText', () => {
  it('catches a real IPv4 address', () => {
    const hits = scanText('profiles/x.zsh', 'export HOST="192.168.1.117"');
    expect(hits.map((h) => h.text)).toEqual(['192.168.1.117']);
  });

  it('catches a real email address', () => {
    const hits = scanText('a.md', 'contact: someone.real@gmail.com');
    expect(hits.map((h) => h.patternId)).toEqual(['email']);
  });

  it('catches a personal home directory path', () => {
    const hits = scanText('a.zsh', 'cd /Users/jrankin/repos');
    expect(hits.map((h) => h.text)).toEqual(['/Users/jrankin']);
  });

  it('catches a private key header', () => {
    const hits = scanText('id_rsa', '-----BEGIN OPENSSH PRIVATE KEY-----');
    expect(hits.map((h) => h.patternId)).toEqual(['private-key']);
  });

  it('reports the line number', () => {
    const hits = scanText('a.zsh', 'one\ntwo\nip=10.0.0.4\n');
    expect(hits[0]?.line).toBe(3);
  });

  it('ignores loopback and unspecified addresses', () => {
    expect(scanText('a.zsh', 'bind 127.0.0.1 and 0.0.0.0 and 255.255.255.255')).toHaveLength(0);
  });

  it('ignores version strings that look like IPs', () => {
    expect(scanText('a.json', '"oxlint": "1.999.0.1"')).toHaveLength(0);
  });

  it('ignores documentation placeholder emails', () => {
    const text = 'you@example.com x@y.com user@example.org noreply@anything.com';
    expect(scanText('a.md', text)).toHaveLength(0);
  });

  it('ignores system and placeholder home segments', () => {
    const text = '/home/linuxbrew/.linuxbrew /home/username /home/directory /home/runner';
    expect(scanText('a.zsh', text)).toHaveLength(0);
  });

  it('still reports a real address in a file that also has placeholders', () => {
    const hits = scanText('a.md', 'you@example.com and real.person@company.io');
    expect(hits.map((h) => h.text)).toEqual(['real.person@company.io']);
  });

  it('treats a templated home path as safe', () => {
    expect(scanText('a.zsh', 'cd /Users/$USER/repos')).toHaveLength(0);
  });
});

describe('isExcluded', () => {
  it('excludes the history-narrating planning docs', () => {
    expect(isExcluded('docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md', DEFAULT_EXCLUDED_PATHS)).toBe(true);
    expect(isExcluded('.agents/handoff.md', DEFAULT_EXCLUDED_PATHS)).toBe(true);
  });

  it('does not exclude ordinary source', () => {
    expect(isExcluded('lib/git.zsh', DEFAULT_EXCLUDED_PATHS)).toBe(false);
  });

  it('excludes test files, whose fixtures are synthetic secrets by design', () => {
    expect(isExcluded('packages/zconf/src/core/scan.test.ts', DEFAULT_EXCLUDED_PATHS)).toBe(true);
    expect(isExcluded('src/__tests__/thing.ts', DEFAULT_EXCLUDED_PATHS)).toBe(true);
  });
});

describe('inline suppression', () => {
  it('skips a line carrying the ignore marker', () => {
    expect(scanText('a.zsh', `HOST=10.1.2.3 # ${IGNORE_MARKER}`)).toHaveLength(0);
  });

  it('still scans the surrounding lines', () => {
    const content = `ok=10.1.2.3 # ${IGNORE_MARKER}\nleak=10.1.2.4\n`;
    expect(scanText('a.zsh', content).map((h) => h.text)).toEqual(['10.1.2.4']);
  });
});

describe('scanRepo', () => {
  it('skips excluded paths but scans the rest', () => {
    const contents = new Map([
      ['docs/todo/notes.md', 'the old host was 10.1.2.3'],
      ['lib/x.zsh', 'HOST=10.1.2.3'],
    ]);
    const hits = scanRepo(contents);
    expect(hits.map((h) => h.file)).toEqual(['lib/x.zsh']);
  });

  it('sorts hits by file then line', () => {
    const contents = new Map([
      ['b.zsh', 'x=10.0.0.1'],
      ['a.zsh', 'one\nx=10.0.0.2'],
    ]);
    expect(scanRepo(contents).map((h) => h.file)).toEqual(['a.zsh', 'b.zsh']);
  });
});
