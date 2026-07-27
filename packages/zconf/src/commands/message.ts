/**
 * `zconf message` — generates a commit message from the pending diff via a
 * local Ollama model. Prints the message to stdout and exits 0 on success;
 * exits non-zero on ANY failure (Ollama not running, no models installed,
 * timeout, empty response) with nothing on stdout, so `zupdate` can fall back
 * to $EDITOR without having to parse an error out of a partial result.
 */

import { execFileSync } from 'node:child_process';

import { buildPrompt, cleanResponse, selectModel } from '../core/commitMessage.js';
import { generate, listInstalledModels, resolveOllamaHost } from '../utils/ollama.js';
import { findRepoRoot } from '../utils/repo.js';

function trackedChangedFiles(root: string): string[] {
  const out = execFileSync('git', ['diff', 'HEAD', '--name-only'], { cwd: root, encoding: 'utf8' });
  return out.split('\n').filter((line) => line.length > 0);
}

function trackedDiff(root: string): string {
  return execFileSync('git', ['diff', 'HEAD'], { cwd: root, encoding: 'utf8', maxBuffer: 1024 * 1024 });
}

export async function message(): Promise<number> {
  const root = findRepoRoot();
  const files = trackedChangedFiles(root);

  if (files.length === 0) {
    // Nothing staged/changed to describe — not an error, just nothing to do.
    return 1;
  }

  const host = resolveOllamaHost();
  const installed = await listInstalledModels(host);
  if (installed.length === 0) return 1;

  const model = selectModel(installed, process.env.OLLAMA_DEFAULT_MODEL);
  if (model === null) return 1;

  const diff = trackedDiff(root);
  const prompt = buildPrompt({ files, diff });

  const raw = await generate(host, model, prompt);
  if (raw === null) return 1;

  const cleaned = cleanResponse(raw);
  if (cleaned.length === 0) return 1;

  console.log(cleaned);
  return 0;
}
