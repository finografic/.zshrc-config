/**
 * Pure logic for AI-generated commit messages: prompt construction, response
 * cleanup, and model selection. Deliberately separated from `commands/message.ts`
 * (which does the actual HTTP calls) so all of this is testable without a
 * running Ollama instance.
 */

/** Same list `update-config.zsh`'s ZU_TYPES / commitlint.config.mjs enforce. */
export const COMMIT_TYPES = [
  'build',
  'chore',
  'ci',
  'deps',
  'docs',
  'feat',
  'fix',
  'refactor',
  'revert',
  'style',
  'test',
] as const;

/** Commitlint.config.mjs's subject-max-length rule. */
export const MAX_SUBJECT_LENGTH = 100;

/**
 * Best latency/quality balance first, from local testing (see .agents/memory.md):
 * `qwen2.5-coder:3b` reliably names the real change (e.g. specific mechanisms,
 * not just touched files), smaller models frequently don't. Only consulted
 * when `OLLAMA_DEFAULT_MODEL` isn't set or isn't installed.
 */
export const MODEL_PREFERENCE: readonly string[] = [
  'qwen2.5-coder:3b',
  'gemma4:e4b-it-qat',
  'gemma4:e4b-mlx',
  'llama3.2:3b',
  'gemma4:12b-mlx',
];

export interface DiffInput {
  readonly files: readonly string[];
  readonly diff: string;
}

/** Caps how much diff text goes in the prompt — keeps latency down and stays well inside context. */
const MAX_DIFF_CHARS = 8000;

function truncateDiff(diff: string): string {
  if (diff.length <= MAX_DIFF_CHARS) return diff;
  return `${diff.slice(0, MAX_DIFF_CHARS)}\n... (diff truncated)`;
}

export function buildPrompt(input: DiffInput): string {
  const fileList = input.files.map((f) => `  ${f}`).join('\n');

  return `You write git commit messages in the Conventional Commits format: \`type(scope): subject\`.

Rules:
- type must be one of: ${COMMIT_TYPES.join(', ')}
- scope is optional — a short word for the area touched (e.g. a directory or module name)
- subject is imperative mood, lowercase, no trailing period, under ${MAX_SUBJECT_LENGTH} characters
- Output ONLY the commit message on a single line. No explanation, no quotes, no markdown, no body.

Changed files:
${fileList}

Diff:
${truncateDiff(input.diff)}

Commit message:`;
}

/**
 * Strips wrapping the model tends to add (backticks, quotes, a leading
 * "Commit message:" echo) and takes the first non-empty line — model output
 * is freeform, not guaranteed single-line despite the prompt asking for it.
 */
export function cleanResponse(raw: string): string {
  const firstLine = raw
    .split('\n')
    .map((line) => line.trim())
    // A line that's only a code-fence marker (```` ``` ```` or ```` ```zsh ````)
    // carries no content — the real message is the line after it.
    .find((line) => line.length > 0 && !/^```[a-z]*$/i.test(line));

  if (firstLine === undefined) return '';

  let cleaned = firstLine;
  cleaned = cleaned.replace(/^commit message:\s*/i, '');
  cleaned = cleaned.replace(/^```[a-z]*\s*|\s*```$/gi, '');
  cleaned = cleaned.replace(/^["'`]+|["'`]+$/g, '');
  cleaned = cleaned.trim();

  if (cleaned.length > MAX_SUBJECT_LENGTH) {
    cleaned = cleaned.slice(0, MAX_SUBJECT_LENGTH).trimEnd();
  }

  return cleaned;
}

/** True when the message already has a conventional-commit type prefix. */
export function hasConventionalType(message: string): boolean {
  const pattern = new RegExp(`^(${COMMIT_TYPES.join('|')})(\\([^)]+\\))?!?:\\s`);
  return pattern.test(message);
}

/** Picks the first preferred model that's actually installed. */
export function selectModel(
  installed: readonly string[],
  preferred: string | undefined,
  fallbackOrder: readonly string[] = MODEL_PREFERENCE,
): string | null {
  if (preferred !== undefined && installed.includes(preferred)) return preferred;

  for (const candidate of fallbackOrder) {
    if (installed.includes(candidate)) return candidate;
  }

  return installed[0] ?? null;
}
