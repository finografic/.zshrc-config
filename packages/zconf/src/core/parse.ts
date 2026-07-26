/**
 * A deliberately small, line-oriented reader for the subset of zsh this repo
 * actually writes.
 *
 * This is NOT a zsh parser — zsh cannot be parsed without implementing zsh.
 * It is a heuristic that answers four questions well enough to lint against
 * the load-model contract: what does this file source, what functions does it
 * define, what runs at top level, and does it start with a shebang.
 *
 * Every heuristic below is covered by tests in `parse.test.ts`, including the
 * cases where it is knowingly approximate.
 */

/** A `source` / `.` statement found in a file. */
export interface SourceRef {
  /** The target exactly as written, e.g. `"$ZSHRC_ROOT/lib/colors.zsh"`. */
  readonly raw: string;
  /**
   * Repo-relative path when the target is statically knowable
   * (`$ZSHRC_ROOT/lib/git.zsh` -> `lib/git.zsh`), else `null` for targets that
   * depend on runtime state (`$ZENV_PATH/...`, `${module}`).
   */
  readonly resolved: string | null;
  /** 1-indexed line number. */
  readonly line: number;
  /** True when the statement sits inside a function body. */
  readonly inFunction: boolean;
}

/** A function definition found in a file. */
export interface FunctionDef {
  readonly name: string;
  /** True when written as `function name()` rather than bare `name()`. */
  readonly usesFunctionKeyword: boolean;
  readonly line: number;
}

/** A statement at brace depth 0 — i.e. one that runs when the file is sourced. */
export interface TopLevelStatement {
  readonly text: string;
  readonly line: number;
  /** First word of the statement, e.g. `export`, `echo`, `[[`. */
  readonly head: string;
  /** True when the statement contains a `$(…)` or backtick command substitution. */
  readonly hasCommandSubstitution: boolean;
}

export interface ParsedZsh {
  readonly hasShebang: boolean;
  readonly sources: SourceRef[];
  readonly functions: FunctionDef[];
  readonly topLevel: TopLevelStatement[];
}

const HEREDOC_START = /<<-?\s*(['"]?)([A-Za-z_][A-Za-z0-9_]*)\1/;
const FUNCTION_DEF = /^(function\s+)?([A-Za-z0-9_:.-]+)\s*\(\s*\)/;
const FUNCTION_KEYWORD_DEF = /^function\s+([A-Za-z0-9_:.-]+)\s*\{/;
const SOURCE_STATEMENT = /^(?:source|\.)\s+(\S+)/;

/**
 * Removes a trailing `# comment`, respecting quotes so that a `#` inside a
 * string (or a `${…}` expansion) is left alone.
 */
export function stripComment(line: string, openQuote: string | null = null): string {
  let quote: string | null = openQuote;

  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];

    if (ch === '\\') {
      i += 1;
      continue;
    }

    if (quote !== null) {
      if (ch === quote) quote = null;
      continue;
    }

    if (ch === '"' || ch === "'") {
      quote = ch;
      continue;
    }

    // Only a `#` that starts a word is a comment: `a#b` is not, `a #b` is.
    if (ch === '#' && (i === 0 || /\s/.test(line[i - 1] ?? ''))) {
      return line.slice(0, i);
    }
  }

  return line;
}

/**
 * Blanks out quoted strings and `${…}` / `$(…)` expansions, so that brace
 * counting sees only structural braces. Without this, a single `${_c}` would
 * look like an opening brace and desynchronise the whole file.
 *
 * `openQuote` carries quote state in and out, because zsh strings span lines —
 * `lib/utils.zsh` embeds a multi-line awk program in single quotes, whose
 * braces would otherwise be counted as shell structure and make every
 * subsequent function body look like top-level code.
 */
export function maskExpansions(
  line: string,
  openQuote: string | null = null,
): {
  readonly masked: string;
  readonly openQuote: string | null;
} {
  let out = '';
  let quote: string | null = openQuote;
  let i = 0;

  while (i < line.length) {
    const ch = line[i] ?? '';
    const next = line[i + 1] ?? '';

    if (ch === '\\') {
      out += '  ';
      i += 2;
      continue;
    }

    if (quote !== null) {
      // Inside single quotes nothing expands; inside double quotes we still
      // need to swallow ${…} and $(…) so their braces are not counted.
      if (quote === '"' && ch === '$' && (next === '{' || next === '(')) {
        const end = matchDelimiter(line, i + 1);
        out += ' '.repeat(end - i + 1);
        i = end + 1;
        continue;
      }
      if (ch === quote) quote = null;
      out += ' ';
      i += 1;
      continue;
    }

    if (ch === '"' || ch === "'") {
      quote = ch;
      out += ' ';
      i += 1;
      continue;
    }

    if (ch === '$' && (next === '{' || next === '(')) {
      const end = matchDelimiter(line, i + 1);
      out += ' '.repeat(end - i + 1);
      i = end + 1;
      continue;
    }

    out += ch;
    i += 1;
  }

  return { masked: out, openQuote: quote };
}

/** Returns the index of the delimiter closing the one that opens at `start`. */
function matchDelimiter(line: string, start: number): number {
  const open = line[start] ?? '';
  const close = open === '{' ? '}' : ')';
  let depth = 0;

  for (let i = start; i < line.length; i += 1) {
    const ch = line[i];
    if (ch === open) depth += 1;
    else if (ch === close) {
      depth -= 1;
      if (depth === 0) return i;
    }
  }

  // Unterminated on this line — treat the rest of the line as consumed.
  return line.length - 1;
}

function countBraces(masked: string): number {
  let delta = 0;
  for (const ch of masked) {
    if (ch === '{') delta += 1;
    else if (ch === '}') delta -= 1;
  }
  return delta;
}

function unquote(value: string): string {
  const trimmed = value.trim();
  if (trimmed.length >= 2) {
    const first = trimmed[0];
    const last = trimmed[trimmed.length - 1];
    if ((first === '"' || first === "'") && first === last) return trimmed.slice(1, -1);
  }
  return trimmed;
}

/**
 * Turns a `source` target into a repo-relative path, or `null` when it cannot
 * be checked statically — either because it depends on runtime state
 * (`$ZENV_PATH/…`) or because it points outside the repo (`~/.zshrc`).
 *
 * `~/.zshrc-config/…` is deliberately still resolved: it names a file inside
 * this repo via a hardcoded home path, which is a portability bug worth
 * reporting rather than a target worth ignoring.
 */
export function resolveSourceTarget(raw: string): string | null {
  const unquoted = unquote(raw);
  const target = unquoted
    .replace(/^\$\{ZSHRC_ROOT\}\/?|^\$ZSHRC_ROOT\/?/, '')
    .replace(/^~\/\.zshrc-config\//, '');

  // Anything still carrying an expansion depends on runtime state.
  if (target.includes('$')) return null;
  if (target.length === 0) return null;
  // Outside the repo — not ours to verify.
  if (target.startsWith('~') || target.startsWith('/')) return null;

  return target;
}

/** True when a `source` target reaches into this repo via a hardcoded path. */
export function isHardcodedRepoPath(raw: string): boolean {
  return unquote(raw).startsWith('~/.zshrc-config/');
}

/**
 * Blanks single-quoted regions only.
 *
 * Needed because `$(…)` inside single quotes does NOT run — `alias lr='find
 * "$(pwd)" …'` defers the subshell to call time, which is the whole point of
 * writing it that way. Testing the raw text would report the fix as the bug.
 */
export function stripSingleQuoted(text: string): string {
  let out = '';
  let inSingle = false;

  for (const ch of text) {
    if (ch === "'") {
      inSingle = !inSingle;
      out += ' ';
      continue;
    }
    out += inSingle ? ' ' : ch;
  }

  return out;
}

/**
 * Strips a `case` branch prefix: `macOS) source "…" ;;` -> `source "…"`.
 *
 * Without this, every `case` branch reads as a statement whose command is
 * `macOS)`, which both hides the `source` inside it (making its target look
 * like an orphan) and produces a nonsense "unrecognised command" report.
 */
export function stripCasePattern(statement: string): string {
  // A branch pattern has no `(` before its `)` — that is what distinguishes it
  // from a function definition or a subshell.
  const match = /^([^()]+)\)\s*(.*)$/.exec(statement);
  if (match === null) return statement;
  return (match[2] ?? '').replace(/\s*;;\s*$/, '').trim();
}

export function parseZsh(content: string): ParsedZsh {
  const lines = content.split('\n');
  const sources: SourceRef[] = [];
  const functions: FunctionDef[] = [];
  const topLevel: TopLevelStatement[] = [];

  let depth = 0;
  let heredocTerminator: string | null = null;
  let openQuote: string | null = null;
  let pending = '';
  let pendingLine = 0;

  for (let index = 0; index < lines.length; index += 1) {
    const rawLine = lines[index] ?? '';
    const lineNumber = index + 1;

    if (heredocTerminator !== null) {
      if (rawLine.trim() === heredocTerminator) heredocTerminator = null;
      continue;
    }

    // A statement continued with a trailing backslash, or left mid-string on
    // the previous line, is not finished yet — accumulate and carry on.
    const quoteAtLineStart = openQuote;
    const withoutCommentRaw = stripComment(rawLine, quoteAtLineStart);
    const maskResult = maskExpansions(withoutCommentRaw, quoteAtLineStart);
    openQuote = maskResult.openQuote;

    const continues = rawLine.trimEnd().endsWith('\\');
    if (openQuote !== null || continues) {
      if (pending.length === 0) pendingLine = lineNumber;
      pending += `${withoutCommentRaw.replace(/\\$/, '')} `;
      depth += countBraces(maskResult.masked);
      if (depth < 0) depth = 0;
      continue;
    }

    const withoutComment = pending.length > 0 ? pending + withoutCommentRaw : withoutCommentRaw;
    const reportedLine = pending.length > 0 ? pendingLine : lineNumber;
    pending = '';

    const statement = withoutComment.trim();
    if (statement.length === 0) continue;

    const { masked } = maskResult;
    const atTopLevel = depth === 0;

    const functionMatch = FUNCTION_DEF.exec(statement) ?? null;
    const keywordMatch = FUNCTION_KEYWORD_DEF.exec(statement) ?? null;

    if (functionMatch !== null) {
      const name = functionMatch[2] ?? '';
      functions.push({
        name,
        usesFunctionKeyword: functionMatch[1] !== undefined,
        line: reportedLine,
      });
    } else if (keywordMatch !== null) {
      functions.push({
        name: keywordMatch[1] ?? '',
        usesFunctionKeyword: true,
        line: reportedLine,
      });
    } else {
      // A `case` branch carries its command after the pattern.
      const effective = stripCasePattern(statement);

      const sourceMatch = SOURCE_STATEMENT.exec(effective) ?? null;
      if (sourceMatch !== null) {
        const raw = sourceMatch[1] ?? '';
        sources.push({
          raw,
          resolved: resolveSourceTarget(raw),
          line: reportedLine,
          inFunction: !atTopLevel,
        });
      }

      if (atTopLevel && effective.length > 0) {
        topLevel.push({
          text: effective,
          line: reportedLine,
          head: effective.split(/\s+/)[0] ?? '',
          hasCommandSubstitution: /\$\(|`/.test(stripSingleQuoted(effective)),
        });
      }
    }

    const heredoc = HEREDOC_START.exec(masked) ?? null;
    if (heredoc !== null) heredocTerminator = heredoc[2] ?? null;

    depth += countBraces(masked);
    if (depth < 0) depth = 0;
  }

  return {
    hasShebang: lines[0]?.startsWith('#!') ?? false,
    sources,
    functions,
    topLevel,
  };
}
