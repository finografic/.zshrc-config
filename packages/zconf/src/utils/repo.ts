import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { Registry } from '../core/manifest.js';
import type { ParsedZsh } from '../core/parse.js';

import { parseRegistry } from '../core/manifest.js';
import { parseZsh } from '../core/parse.js';

export interface Repo {
  readonly root: string;
  /** Repo-relative paths of every tracked file. */
  readonly trackedFiles: string[];
  readonly registry: Registry;
  /** Repo-relative path -> raw contents, for tracked `.zsh` files. */
  readonly contents: ReadonlyMap<string, string>;
  /** Repo-relative path -> parsed contents, for tracked `.zsh` files. */
  readonly parsed: ReadonlyMap<string, ParsedZsh>;
}

/**
 * Finds the repo root. Uses `git rev-parse` so the CLI works from any
 * subdirectory, and falls back to walking up from this file for the case where
 * git is unavailable.
 */
export function findRepoRoot(from: string = process.cwd()): string {
  try {
    return execFileSync('git', ['rev-parse', '--show-toplevel'], {
      cwd: from,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
  } catch {
    // packages/zconf/dist/index.js -> repo root
    return resolve(dirname(fileURLToPath(import.meta.url)), '../../..');
  }
}

function listTrackedFiles(root: string): string[] {
  const out = execFileSync('git', ['ls-files', '-z'], { cwd: root, encoding: 'utf8' });
  return out.split('\0').filter((path) => path.length > 0);
}

/**
 * True when git deliberately ignores a path. Used so that an optional,
 * untracked-by-design target like `.env` is not reported as a broken source.
 */
export function makeIsIgnored(root: string): (path: string) => boolean {
  const cache = new Map<string, boolean>();

  return (path: string): boolean => {
    const cached = cache.get(path);
    if (cached !== undefined) return cached;

    let ignored = false;
    try {
      execFileSync('git', ['check-ignore', '--quiet', '--no-index', path], {
        cwd: root,
        stdio: 'ignore',
      });
      ignored = true;
    } catch {
      ignored = false;
    }

    cache.set(path, ignored);
    return ignored;
  };
}

export function loadRepo(root: string = findRepoRoot()): Repo {
  const trackedFiles = listTrackedFiles(root);
  const contents = new Map<string, string>();
  const parsed = new Map<string, ParsedZsh>();

  for (const path of trackedFiles) {
    if (!path.endsWith('.zsh') && !path.endsWith('.zsh-theme')) continue;
    const text = readFileSync(resolve(root, path), 'utf8');
    contents.set(path, text);
    parsed.set(path, parseZsh(text));
  }

  const registrySource = contents.get('core/profile.zsh') ?? '';

  return { root, trackedFiles, registry: parseRegistry(registrySource), contents, parsed };
}

/**
 * Files the shell loads directly, rather than via a `source` from another
 * tracked file. `.zshrc` is the real-world entry point; the rest are what it
 * and `main.zsh` reach unconditionally.
 */
export const ENTRY_POINTS: readonly string[] = [
  '.zshrc',
  'main.zsh',
  'main-splash.zsh',
  'bootstrap/index.zsh',
];
