#!/usr/bin/env tsx
// ============================================================================
// BUILD-PATH - PATH deduplication and validation for zshrc-config
// ============================================================================
// Outputs a clean PATH with duplicates removed:
//   export PATH="$(tsx node/src/build-path.ts)"
// ============================================================================

import { existsSync } from 'fs';

interface Options {
  validateExists: boolean;
  verbose: boolean;
}

function getOptions(): Options {
  return {
    validateExists: process.argv.includes('--validate'),
    verbose: process.argv.includes('--verbose'),
  };
}

function buildPath(currentPath: string, options: Options): string {
  const paths = currentPath.split(':');
  const seen = new Set<string>();
  const result: string[] = [];
  const removed: string[] = [];
  const invalid: string[] = [];

  for (const p of paths) {
    // Skip empty entries
    if (!p) continue;

    // Skip duplicates
    if (seen.has(p)) {
      removed.push(p);
      continue;
    }

    // Optionally validate path exists
    if (options.validateExists && !existsSync(p)) {
      invalid.push(p);
      continue;
    }

    seen.add(p);
    result.push(p);
  }

  if (options.verbose) {
    if (removed.length > 0) {
      console.error(`Removed ${removed.length} duplicate(s): ${removed.join(', ')}`);
    }
    if (invalid.length > 0) {
      console.error(`Removed ${invalid.length} invalid path(s): ${invalid.join(', ')}`);
    }
  }

  return result.join(':');
}

function main(): void {
  const currentPath = process.env.PATH ?? '';
  const options = getOptions();
  const cleanPath = buildPath(currentPath, options);
  console.log(cleanPath);
}

main();
