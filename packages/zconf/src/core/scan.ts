/**
 * Secret / PII scanning.
 *
 * This mirrors the `secret-scan` job in `.github/workflows/ci.yml`, with the
 * same allowlist reasoning: loopback and unspecified IPs are not PII, and
 * `docs/todo/**` + `.agents/**` legitimately narrate old host/profile history,
 * so they are exempt by path rather than by weakening the pattern for everyone.
 */

export interface ScanPattern {
  readonly id: string;
  readonly description: string;
  readonly pattern: RegExp;
}

export interface ScanHit {
  readonly file: string;
  readonly line: number;
  readonly patternId: string;
  readonly text: string;
}

/** IPs that carry no information about a person or a host. */
const IP_ALLOWLIST = new Set(['127.0.0.1', '0.0.0.0', '255.255.255.255', '0.0.0.1']);

/**
 * Documentation placeholders and system accounts.
 *
 * A scanner that reports `you@example.com` in a `.example` file, or
 * `/home/linuxbrew` (a package manager's install prefix, not a person), trains
 * its reader to skim past it — and the one real hit then goes unnoticed. These
 * are excluded by *value*, so a real address in the same file still reports.
 */
const PLACEHOLDER_EMAIL_DOMAINS = new Set(['example.com', 'example.org', 'example.net', 'y.com']);

const PLACEHOLDER_EMAIL_LOCALS = new Set([
  'you',
  'your',
  'user',
  'username',
  'me',
  'name',
  'x',
  'foo',
  'bar',
  'noreply',
  'email',
]);

/** `/home/<segment>` values that name a system account or a placeholder. */
const NON_PERSONAL_HOME_SEGMENTS = new Set([
  'linuxbrew',
  'username',
  'user',
  'yourname',
  'youruser',
  'directory',
  'name',
  'me',
  'someone',
  'runner',
  'node',
  'root',
]);

export const DEFAULT_PATTERNS: readonly ScanPattern[] = [
  {
    id: 'ipv4',
    description: 'IPv4 literal',
    pattern: /\b(?:\d{1,3}\.){3}\d{1,3}\b/g,
  },
  {
    id: 'email',
    description: 'email address',
    pattern: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/g,
  },
  {
    id: 'home-path',
    description: 'absolute home directory path',
    pattern: /\/(?:Users|home)\/(?!\w*\$)[a-z][a-z0-9._-]*/g,
  },
  {
    id: 'private-key',
    description: 'private key block',
    pattern: /-----BEGIN (?:RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----/g,
  },
];

/** Paths that are allowed to contain matches, and why. */
export const DEFAULT_EXCLUDED_PATHS: readonly string[] = [
  'docs/todo/',
  '.agents/',
  'pnpm-lock.yaml',
  'package-lock.json',
  '.github/workflows/ci.yml',
  'docs/benchmarks/',
];

/**
 * Opt-out marker for a line that must contain a PII-shaped literal — the
 * scanner's own fixtures being the obvious case. Visible in review, unlike a
 * silently broadened pattern.
 */
export const IGNORE_MARKER = 'zconf-scan-ignore';

/** Test files assert against synthetic secrets; that is their job. */
function isTestFile(path: string): boolean {
  return /\.(?:test|spec)\.[cm]?[jt]sx?$/.test(path) || path.includes('__tests__/');
}

export function isExcluded(path: string, excluded: readonly string[]): boolean {
  if (isTestFile(path)) return true;
  return excluded.some((prefix) => path === prefix || path.startsWith(prefix));
}

function isAllowedMatch(patternId: string, text: string): boolean {
  if (patternId === 'ipv4') {
    // Dotted version-like numbers and the allowlisted addresses are noise.
    if (IP_ALLOWLIST.has(text)) return true;
    const octets = text.split('.').map((part) => Number.parseInt(part, 10));
    return octets.some((octet) => octet > 255);
  }

  if (patternId === 'home-path') {
    // `/Users/` or `/home/` with a variable straight after is a template.
    if (/\/(?:Users|home)\/$/.test(text)) return true;
    const segment = text.split('/')[2] ?? '';
    return NON_PERSONAL_HOME_SEGMENTS.has(segment.toLowerCase());
  }

  if (patternId === 'email') {
    const [local = '', domain = ''] = text.toLowerCase().split('@');
    return PLACEHOLDER_EMAIL_DOMAINS.has(domain) || PLACEHOLDER_EMAIL_LOCALS.has(local);
  }

  return false;
}

/** Scans one file's text. Pure: takes content, returns hits. */
export function scanText(
  file: string,
  content: string,
  patterns: readonly ScanPattern[] = DEFAULT_PATTERNS,
): ScanHit[] {
  const hits: ScanHit[] = [];
  const lines = content.split('\n');

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index] ?? '';
    if (line.includes(IGNORE_MARKER)) continue;

    for (const { id, pattern } of patterns) {
      // A fresh regex per line: the shared literals carry the /g flag and
      // therefore lastIndex state.
      const local = new RegExp(pattern.source, pattern.flags);
      for (const match of line.matchAll(local)) {
        const text = match[0];
        if (isAllowedMatch(id, text)) continue;
        hits.push({ file, line: index + 1, patternId: id, text });
      }
    }
  }

  return hits;
}

export function scanRepo(
  contents: ReadonlyMap<string, string>,
  options: {
    readonly patterns?: readonly ScanPattern[];
    readonly excluded?: readonly string[];
  } = {},
): ScanHit[] {
  const patterns = options.patterns ?? DEFAULT_PATTERNS;
  const excluded = options.excluded ?? DEFAULT_EXCLUDED_PATHS;
  const hits: ScanHit[] = [];

  for (const [file, content] of contents) {
    if (isExcluded(file, excluded)) continue;
    hits.push(...scanText(file, content, patterns));
  }

  return hits.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line);
}
