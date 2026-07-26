import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  buildRenames,
  collectFunctionNames,
  normalizeCommentBlocks,
  normalizeFunctions,
  shouldSkipForNormalize,
} from '../core/normalize.js';
import { pc } from '../utils/picocolors.js';
import { loadRepo } from '../utils/repo.js';

export interface NormalizeOptions {
  /** Report what would change without writing anything. */
  readonly dryRun: boolean;
  /** Restrict to one pass. */
  readonly only: 'comments' | 'functions' | null;
}

export function normalize(options: NormalizeOptions): number {
  const repo = loadRepo();

  const targets = [...repo.contents.keys()].filter((path) => !shouldSkipForNormalize(path)).sort();
  const originals = new Map(targets.map((path) => [path, repo.contents.get(path) ?? '']));

  const runComments = options.only === null || options.only === 'comments';
  const runFunctions = options.only === null || options.only === 'functions';

  // The function pass needs the whole-repo name set before it can rewrite any
  // single file, since renaming a definition must rename its call sites too.
  const renames = runFunctions
    ? buildRenames(collectFunctionNames(originals.values()))
    : new Map<string, string>();

  const changed: string[] = [];

  for (const path of targets) {
    const original = originals.get(path) ?? '';
    let next = original;

    if (runComments) next = normalizeCommentBlocks(next);
    if (runFunctions) next = normalizeFunctions(next, renames);

    if (next === original) continue;

    changed.push(path);
    if (!options.dryRun) writeFileSync(resolve(repo.root, path), next);
  }

  if (renames.size > 0) {
    console.log(pc.bold(`${renames.size} function rename(s):`));
    const ordered = [...renames].sort((a, b) => a[0].localeCompare(b[0]));
    for (const [old, next] of ordered) console.log(`  ${old} ${pc.gray('->')} ${next}`);
    console.log('');
  }

  if (changed.length === 0) {
    console.log(pc.green(`✔ normalize: nothing to change (${targets.length} files)`));
    return 0;
  }

  const verb = options.dryRun ? 'would change' : 'changed';
  console.log(pc.bold(`${verb} ${changed.length} file(s):`));
  for (const path of changed) console.log(`  ${path}`);

  if (options.dryRun) {
    console.log('');
    console.log(pc.gray('re-run without --dry-run to apply'));
  }

  return 0;
}

/** Reads a file the normaliser would rewrite, for callers wanting a preview. */
export function previewNormalized(root: string, path: string): string {
  const original = readFileSync(resolve(root, path), 'utf8');
  return normalizeCommentBlocks(original);
}
