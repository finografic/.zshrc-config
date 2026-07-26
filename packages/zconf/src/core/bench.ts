/**
 * Benchmark reporting.
 *
 * The *measuring* stays in `scripts/bench-startup.zsh` — it has to spawn real
 * shells, and it must keep working on a machine with no Node. This module only
 * does the parts that benefit from types and tests: parsing its output,
 * diffing against the recorded baseline, and rendering the table.
 */

import type { Summary } from './stats.js';

import { delta, formatDelta, formatMs } from './stats.js';

export interface ProfileTiming {
  readonly min: number;
  readonly p50: number;
  readonly p95: number;
}

export interface Baseline {
  readonly date: string;
  readonly runs: number;
  readonly host: string;
  readonly profiles: Record<string, ProfileTiming>;
}

interface RawBaseline {
  date?: unknown;
  runs?: unknown;
  host?: unknown;
  profiles?: unknown;
}

function toTiming(value: unknown): ProfileTiming | null {
  if (typeof value !== 'object' || value === null) return null;

  const record = value as Record<string, unknown>;
  const min = record.min_ms;
  const p50 = record.p50_ms;
  const p95 = record.p95_ms;

  if (typeof min !== 'number' || typeof p50 !== 'number' || typeof p95 !== 'number') return null;
  return { min, p50, p95 };
}

/** Parses the JSON that `bench-startup.zsh --json` / `--save` produces. */
export function parseBenchJson(text: string): Baseline {
  const parsed = JSON.parse(text) as RawBaseline;
  const profiles: Record<string, ProfileTiming> = {};

  if (typeof parsed.profiles === 'object' && parsed.profiles !== null) {
    for (const [name, value] of Object.entries(parsed.profiles as Record<string, unknown>)) {
      const timing = toTiming(value);
      if (timing !== null) profiles[name] = timing;
    }
  }

  return {
    date: typeof parsed.date === 'string' ? parsed.date : '',
    runs: typeof parsed.runs === 'number' ? parsed.runs : 0,
    host: typeof parsed.host === 'string' ? parsed.host : '',
    profiles,
  };
}

export function summaryToTiming(summary: Summary): ProfileTiming {
  return { min: summary.min, p50: summary.p50, p95: summary.p95 };
}

export interface ComparisonRow {
  readonly profile: string;
  readonly current: ProfileTiming | null;
  readonly baseline: ProfileTiming | null;
  /** Signed fraction on p50; NaN when either side is missing. */
  readonly change: number;
}

/**
 * Joins a fresh run against the baseline. Profiles present in only one side
 * are still listed — a profile that vanished from a run is itself a finding.
 */
export function compareToBaseline(
  current: Readonly<Record<string, ProfileTiming>>,
  baseline: Readonly<Record<string, ProfileTiming>>,
): ComparisonRow[] {
  const names = [...new Set([...Object.keys(current), ...Object.keys(baseline)])].sort();

  return names.map((profile) => {
    const now = current[profile] ?? null;
    const before = baseline[profile] ?? null;

    return {
      profile,
      current: now,
      baseline: before,
      change: now === null || before === null ? Number.NaN : delta(before.p50, now.p50),
    };
  });
}

/** Fixed-width table, matching the shape `bench-startup.zsh` already prints. */
export function renderComparison(rows: readonly ComparisonRow[]): string {
  const header = ['PROFILE', 'MIN(ms)', 'P50(ms)', 'P95(ms)', 'VS BASE'];
  const widths = [16, 9, 9, 9, 9];

  const line = (cells: readonly string[]): string =>
    cells
      .map((cell, index) => cell.padEnd(widths[index] ?? 0))
      .join('')
      .trimEnd();

  const body = rows.map((row) =>
    line([
      row.profile,
      row.current === null ? '—' : formatMs(row.current.min),
      row.current === null ? '—' : formatMs(row.current.p50),
      row.current === null ? '—' : formatMs(row.current.p95),
      formatDelta(row.change),
    ]),
  );

  return [line(header), ...body].join('\n');
}

/** A regression worth failing on, expressed as a fraction (0.2 = 20% slower). */
export function regressions(rows: readonly ComparisonRow[], threshold: number): ComparisonRow[] {
  return rows.filter((row) => !Number.isNaN(row.change) && row.change > threshold);
}
