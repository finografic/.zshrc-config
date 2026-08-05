import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { DEFAULT_EXCLUDED_PATHS, isExcluded, scanText } from '../core/scan.js';
import { pc } from '../utils/picocolors.js';
import { findRepoRoot } from '../utils/repo.js';

/** Extensions worth scanning — binaries and lockfiles only generate noise. */
const TEXT_EXTENSIONS = new Set([
  '.zsh',
  '.sh',
  '.md',
  '.ts',
  '.js',
  '.mjs',
  '.json',
  '.jsonc',
  '.yml',
  '.yaml',
  '.toml',
  '.conf',
  '.config',
  '.theme',
  '.zsh-theme',
  '.py',
  '.example',
  '.txt',
]);

function hasScannableExtension(path: string): boolean {
  const base = path.split('/').pop() ?? path;
  if (!base.includes('.')) return false;
  const ext = base.slice(base.lastIndexOf('.'));
  return TEXT_EXTENSIONS.has(ext);
}

export function scan(): number {
  const root = findRepoRoot();
  const tracked = execFileSync('git', ['ls-files', '-z'], { cwd: root, encoding: 'utf8' })
    .split('\0')
    .filter((path) => path.length > 0);

  const hits = [];

  for (const path of tracked) {
    if (isExcluded(path, DEFAULT_EXCLUDED_PATHS)) continue;
    if (!hasScannableExtension(path)) continue;

    let content: string;
    try {
      content = readFileSync(resolve(root, path), 'utf8');
    } catch {
      continue;
    }

    hits.push(...scanText(path, content));
  }

  if (hits.length === 0) {
    console.log(pc.green(`✔ scan: no secrets or PII found (${tracked.length} tracked files)`));
    return 0;
  }

  for (const hit of hits) {
    console.log(`${pc.bold(`${hit.file}:${hit.line}`)} ${pc.red(hit.text)} ${pc.gray(`[${hit.patternId}]`)}`);
  }

  console.log('');
  console.log(pc.red(`✖ scan: ${hits.length} possible secret/PII match(es)`));
  return 1;
}
