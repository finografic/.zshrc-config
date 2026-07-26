/**
 * Ports `scripts/normalize-comment-blocks.py` and
 * `scripts/normalize-functions.py`, so the repo has one tooling language
 * instead of three and the normalisers are finally testable.
 *
 * Behaviour is intentionally identical to the Python originals — this is a
 * port, not a redesign. Where the Python was ambiguous the tests pin down
 * what it actually did.
 */

export const CANONICAL_SEPARATOR =
  '# ============================================================================ #';

/** Zsh hook and widget names that must keep their exact spelling. */
export const PROTECTED_FUNCTION_NAMES: ReadonlySet<string> = new Set([
  'precmd',
  'preexec',
  'chpwd',
  'periodic',
  'up-line-or-history-substring-search-up',
  'down-line-or-history-substring-search-down',
  'expand-or-complete-with-dots',
]);

// ---------------------------------------------------------------------------
// Comment blocks
// ---------------------------------------------------------------------------

export function isSeparatorLine(line: string): boolean {
  const stripped = line.replace(/\n$/, '');
  if (!stripped.startsWith('#')) return false;

  const rest = stripped.slice(1).trim();
  if (rest.length === 0) return false;

  const core = rest.replace(/#+$/, '').trim();
  if (core.length === 0) return false;

  return /^=+$/.test(core) || /^-+$/.test(core);
}

export function isHashOnlyLine(line: string): boolean {
  const stripped = line.replace(/\n$/, '');
  if (!stripped.startsWith('#')) return false;

  const content = stripped.slice(1).replaceAll(' ', '');
  return /^#+$/.test(content);
}

export function isHashTitleLine(line: string): boolean {
  const stripped = line.replace(/\n$/, '');
  if (!stripped.startsWith('#')) return false;
  if (isHashOnlyLine(line) || isSeparatorLine(line)) return false;

  const inner = stripped.slice(1);
  const text = inner.replaceAll('#', '').trim();
  return text.length > 0 && inner.includes('#');
}

export function extractHashTitle(line: string): string {
  return line.replaceAll('#', ' ').split(/\s+/).filter(Boolean).join(' ');
}

function isTitleLine(line: string): boolean {
  const stripped = line.replace(/\n$/, '');
  if (!stripped.startsWith('#')) return false;
  if (isSeparatorLine(line) || isHashOnlyLine(line)) return false;

  const rest = stripped.slice(1);
  if (/^\s*-\s/.test(rest)) return false;

  return rest.trim().length > 0;
}

/** Prose continuations are not section titles, so they keep their own line. */
const PROSE_STARTS = ['This ', 'These ', 'The ', 'For ', 'When ', 'If ', 'Loads ', 'Installs ', 'Usage:'];

export function isSectionTitleLine(line: string): boolean {
  if (!isTitleLine(line)) return false;

  const content = line.replace(/\n$/, '').slice(1).trim();
  if (content.startsWith('NOTE:')) return true;

  return !PROSE_STARTS.some((prefix) => content.startsWith(prefix));
}

export function extractInlineTitle(line: string): string | null {
  const match = /^#\s+(.+?)\s+=+$/.exec(line.replace(/\n$/, ''));
  return match?.[1]?.trim() ?? null;
}

function makeBlock(title: string): string[] {
  return [CANONICAL_SEPARATOR, `# ${title}`, CANONICAL_SEPARATOR];
}

function isCommentLine(line: string): boolean {
  return line.trimStart().startsWith('#');
}

/**
 * Finds the separator that closes the block opening at `start`, scanning only
 * across an unbroken run of comment lines. Returns -1 when the run ends
 * without one.
 */
function findClosingSeparator(lines: readonly string[], start: number): number {
  for (let i = start + 1; i < lines.length; i += 1) {
    const line = lines[i] ?? '';
    if (!isCommentLine(line)) return -1;
    if (isSeparatorLine(line)) return i;
  }
  return -1;
}

/**
 * SECOND deliberate deviation from the Python original, and the one that
 * matters.
 *
 * The Python matched a fixed three-line block, then fell through to a
 * "malformed two-line block" rule that emitted a closing rule immediately
 * after the title. Against this repo that is destructive: almost every block
 * here is
 *
 *     # ===
 *     # NOTE: TITLE
 *     # explanatory prose, sometimes many lines
 *     # ===
 *
 * And the two-line rule fires on the first two lines, injects a closing rule
 * after the title, and shoves the prose out of the block. Running the Python
 * today would mangle the comment blocks in 28 files.
 *
 * This version instead scans forward for the real closing separator across the
 * unbroken comment run and rewrites only the two rules, leaving every body
 * line untouched. A separator with no closing partner is normalised in place
 * rather than having a block invented around it — guessing where an unclosed
 * block ends is what caused the damage in the first place.
 */
export function normalizeCommentBlocks(content: string): string {
  if (content.length === 0) return content;

  const trailingNewline = content.endsWith('\n') ? '\n' : '';
  const lines = content.split('\n');
  // `split` leaves a trailing '' for a file ending in a newline.
  if (trailingNewline !== '') lines.pop();

  const out: string[] = [];
  let i = 0;

  const nonBlankFollows = (index: number): boolean => (lines[index] ?? '').trim().length > 0;

  while (i < lines.length) {
    const line = lines[i] ?? '';

    // Three-line hash block: #### / # TITLE # / ####
    if (
      i + 2 < lines.length &&
      isHashOnlyLine(line) &&
      isHashTitleLine(lines[i + 1] ?? '') &&
      isHashOnlyLine(lines[i + 2] ?? '')
    ) {
      out.push(...makeBlock(extractHashTitle(lines[i + 1] ?? '')));
      if (i + 3 < lines.length && nonBlankFollows(i + 3)) out.push('');
      i += 3;
      continue;
    }

    if (isSeparatorLine(line)) {
      const close = findClosingSeparator(lines, i);

      if (close !== -1) {
        // Rewrite the rules; keep everything between them exactly as written.
        out.push(CANONICAL_SEPARATOR);
        for (let body = i + 1; body < close; body += 1) out.push(lines[body] ?? '');
        out.push(CANONICAL_SEPARATOR);
        if (close + 1 < lines.length && nonBlankFollows(close + 1)) out.push('');
        i = close + 1;
        continue;
      }

      out.push(CANONICAL_SEPARATOR);
      i += 1;
      continue;
    }

    // Inline trailing equals: `# Title =====`.
    const inlineTitle = extractInlineTitle(line);
    if (inlineTitle !== null) {
      out.push(...makeBlock(inlineTitle));
      if (i + 1 < lines.length && nonBlankFollows(i + 1)) out.push('');
      i += 1;
      continue;
    }

    out.push(line);
    i += 1;
  }

  return out.join('\n') + trailingNewline;
}

// ---------------------------------------------------------------------------
// Function definitions
// ---------------------------------------------------------------------------

const DEF_RE = /^(\s*)(?:function\s+)?([a-zA-Z_][-a-zA-Z0-9_]*)\s*\(\)\s*(\{.*)$/;

/**
 * ONE deliberate deviation from `scripts/normalize-functions.py`.
 *
 * The Python builds its output as `f"{indent}function {name}(){tail}"`, where
 * `tail` starts at the brace — so it emits `function thing(){`, with no space.
 * Verified by running it: every one of this repo's ~200 `function x() {`
 * definitions would have the space stripped, which is both contrary to the
 * repo's own established style and several hundred lines of pure churn. That
 * is very likely why the script has not been run in a long time.
 *
 * The port emits `function thing() {`. Everything else is faithful.
 */
function renderDefinition(indent: string, name: string, tail: string): string {
  return `${indent}function ${name}() ${tail}`;
}

/** `my_thing` -> `my-thing`, preserving any leading underscore prefix. */
export function toKebab(name: string): string {
  if (!name.includes('_')) return name;

  let lead = '';
  let rest = name;
  while (rest.startsWith('_')) {
    lead += '_';
    rest = rest.slice(1);
  }

  const parts = rest.split('_').filter((part) => part.length > 0);
  return lead + parts.map((part) => part.toLowerCase()).join('-');
}

export function collectFunctionNames(contents: Iterable<string>): Set<string> {
  const names = new Set<string>();

  for (const text of contents) {
    for (const line of text.split('\n')) {
      const match = DEF_RE.exec(line);
      const name = match?.[2];
      if (name !== undefined) names.add(name);
    }
  }

  return names;
}

export function buildRenames(names: Iterable<string>): Map<string, string> {
  const renames = new Map<string, string>();

  for (const name of names) {
    if (PROTECTED_FUNCTION_NAMES.has(name)) continue;
    const next = toKebab(name);
    if (next !== name) renames.set(name, next);
  }

  return renames;
}

function normalizeDefLine(line: string, renames: ReadonlyMap<string, string>): string {
  const match = DEF_RE.exec(line);
  if (match === null) return line;

  const indent = match[1] ?? '';
  const name = match[2] ?? '';
  const tail = match[3] ?? '';

  if (PROTECTED_FUNCTION_NAMES.has(name)) {
    return /^\s*function\s+/.test(line) ? line : renderDefinition(indent, name, tail);
  }

  return renderDefinition(indent, renames.get(name) ?? name, tail);
}

function escapeRegExp(value: string): string {
  return value.replaceAll(/[.*+?^${}()|[\]\\]/g, String.raw`\$&`);
}

/**
 * Applies renames across a whole file body, longest name first so that a
 * shorter name is never substituted inside a longer one.
 */
export function applyRenames(text: string, renames: ReadonlyMap<string, string>): string {
  if (renames.size === 0) return text;

  const ordered = [...renames.entries()].sort((a, b) => b[0].length - a[0].length);
  let out = text;

  for (const [old, next] of ordered) {
    out = out.replaceAll(new RegExp(`(?<![a-zA-Z0-9_-])${escapeRegExp(old)}(?![a-zA-Z0-9_-])`, 'g'), next);
  }

  return out;
}

export function normalizeFunctions(content: string, renames: ReadonlyMap<string, string>): string {
  const trailingNewline = content.endsWith('\n') ? '\n' : '';
  const lines = content.split('\n');
  if (trailingNewline !== '') lines.pop();

  const rewritten = lines.map((line) => normalizeDefLine(line, renames)).join('\n') + trailingNewline;
  return applyRenames(rewritten, renames);
}

/** Paths the function normaliser must not touch. */
export const NORMALIZE_SKIP_DIRS: readonly string[] = ['.git/', '.claude/', 'vendor/', 'node_modules/'];

export const NORMALIZE_SKIP_FILES: readonly string[] = ['scripts/.iterm2_shell_integration.zsh'];

export const NORMALIZE_SKIP_PREFIXES: readonly string[] = [
  'themes/p10k/$HOME.cache/',
  'plugins/.zsh_plugins.generated',
];

export function shouldSkipForNormalize(path: string): boolean {
  if (NORMALIZE_SKIP_FILES.includes(path)) return true;
  if (NORMALIZE_SKIP_DIRS.some((dir) => path.startsWith(dir) || path.includes(`/${dir}`))) return true;
  if (NORMALIZE_SKIP_PREFIXES.some((prefix) => path.startsWith(prefix))) return true;
  return path.includes('p10k-dump');
}
