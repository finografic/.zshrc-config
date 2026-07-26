import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { compareToBaseline, parseBenchJson, regressions, renderComparison } from '../core/bench.js';
import { pc } from '../utils/picocolors.js';
import { findRepoRoot } from '../utils/repo.js';

export interface BenchOptions {
  readonly runs: number;
  readonly profile: string | null;
  /** Fail if any profile is more than this fraction slower than baseline. */
  readonly threshold: number;
}

/**
 * Wraps `scripts/bench-startup.zsh`. The measuring stays in zsh — it spawns
 * real shells and has to work without Node — so this only runs it, parses the
 * JSON, and does the diff and formatting.
 */
export function bench(options: BenchOptions): number {
  const root = findRepoRoot();
  const script = resolve(root, 'scripts/bench-startup.zsh');

  const args = ['-n', String(options.runs), '--json'];
  if (options.profile === null) args.push('--all-profiles');
  else args.push('--zenv', options.profile);

  console.log(pc.gray(`running ${options.runs} shells per profile — this takes a moment…`));

  let output: string;
  try {
    output = execFileSync('zsh', [script, ...args], { cwd: root, encoding: 'utf8' });
  } catch (error) {
    console.error(pc.red('bench: scripts/bench-startup.zsh failed'));
    if (error instanceof Error) console.error(pc.gray(error.message));
    return 1;
  }

  const current = parseBenchJson(output);

  let baselineProfiles = {};
  try {
    baselineProfiles = parseBenchJson(
      readFileSync(resolve(root, 'docs/benchmarks/baseline.json'), 'utf8'),
    ).profiles;
  } catch {
    console.log(pc.yellow('no baseline recorded yet — showing raw timings'));
  }

  // When one profile was asked for, do not pad the table with every other
  // profile the baseline happens to know about.
  const allRows = compareToBaseline(current.profiles, baselineProfiles);
  const rows = options.profile === null ? allRows : allRows.filter((row) => row.profile === options.profile);

  console.log('');
  console.log(renderComparison(rows));
  console.log('');

  const slower = regressions(rows, options.threshold);
  if (slower.length === 0) {
    console.log(pc.green('✔ bench: no regression beyond threshold'));
    return 0;
  }

  for (const row of slower) {
    console.log(pc.red(`✖ ${row.profile} is slower than baseline by more than ${options.threshold * 100}%`));
  }

  // Deliberately not a hard failure by default: these numbers move with
  // machine load, and a benchmark that cries wolf gets ignored. See
  // docs/benchmarks/README.md on why absolute numbers from a shared or
  // virtualised runner are not trustworthy on their own.
  console.log(pc.gray('treat as a signal to investigate, not proof of a regression'));
  return 0;
}
