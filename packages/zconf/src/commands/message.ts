/**
 * `zconf message` — generates a commit message from the pending diff via a
 * local Ollama model. Prints the message to stdout and exits 0 on success;
 * exits non-zero on ANY failure (Ollama not running, no models installed,
 * timeout, empty response) with nothing on stdout, so `zupdate` can fall back
 * to $EDITOR without having to parse an error out of a partial result.
 *
 * On success, the model name and generation latency go to stderr (never
 * stdout) — metadata for the caller to display, not part of the message.
 */

import { execFileSync } from 'node:child_process';

import { buildPrompt, cleanResponse, selectModel } from '../core/commitMessage.js';
import { generate, listInstalledModels, resolveOllamaHost } from '../utils/ollama.js';
import { findRepoRoot } from '../utils/repo.js';

function trackedChangedFiles(root: string, staged: boolean): string[] {
  const base = staged ? ['diff', '--cached'] : ['diff', 'HEAD'];
  const out = execFileSync('git', [...base, '--name-only'], { cwd: root, encoding: 'utf8' });
  return out.split('\n').filter((line) => line.length > 0);
}

function trackedDiff(root: string, staged: boolean): string {
  const base = staged ? ['diff', '--cached'] : ['diff', 'HEAD'];
  return execFileSync('git', base, { cwd: root, encoding: 'utf8', maxBuffer: 1024 * 1024 });
}

export interface MessageOptions {
  /**
   * Diff staged changes only (`git diff --cached`) instead of all tracked changes
   * against HEAD. Used by `_gc --ai`, which commits staged files only — describing
   * unstaged tracked changes too would draft a message for files not being committed.
   */
  readonly staged?: boolean;
}

export async function message(options: MessageOptions = {}): Promise<number> {
  const staged = options.staged ?? false;
  const root = findRepoRoot();
  const files = trackedChangedFiles(root, staged);

  if (files.length === 0) {
    // Nothing staged/changed to describe — not an error, just nothing to do.
    return 1;
  }

  const host = resolveOllamaHost();
  const installed = await listInstalledModels(host);
  if (installed.length === 0) return 1;

  const model = selectModel(installed, process.env.OLLAMA_DEFAULT_MODEL);
  if (model === null) return 1;

  const diff = trackedDiff(root, staged);
  const prompt = buildPrompt({ files, diff });

  const startedAt = Date.now();
  const raw = await generate(host, model, prompt);
  const elapsedMs = Date.now() - startedAt;
  if (raw === null) return 1;

  const cleaned = cleanResponse(raw);
  if (cleaned.length === 0) return 1;

  console.log(cleaned);
  console.error(`${model}  ${elapsedMs}ms`);
  return 0;
}
