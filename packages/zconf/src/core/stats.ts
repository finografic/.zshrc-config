/** Benchmark statistics. Pure, so the numbers in the README are testable. */

export interface Summary {
  readonly n: number;
  readonly min: number;
  readonly p50: number;
  readonly p95: number;
  readonly max: number;
  readonly mean: number;
}

/**
 * Nearest-rank percentile: the smallest sample at or above the requested
 * position. Chosen over interpolation because it always returns a value that
 * was actually measured — for 10 runs of a shell, an invented 94.7 ms that no
 * run produced is worse than the honest neighbouring sample.
 */
export function percentile(sorted: readonly number[], fraction: number): number {
  if (sorted.length === 0) return Number.NaN;
  const rank = Math.ceil(fraction * sorted.length);
  const index = Math.min(Math.max(rank - 1, 0), sorted.length - 1);
  return sorted[index] ?? Number.NaN;
}

export function summarise(samples: readonly number[]): Summary {
  const sorted = [...samples].sort((a, b) => a - b);
  const n = sorted.length;
  const total = sorted.reduce((sum, value) => sum + value, 0);

  return {
    n,
    min: sorted[0] ?? Number.NaN,
    p50: percentile(sorted, 0.5),
    p95: percentile(sorted, 0.95),
    max: sorted[n - 1] ?? Number.NaN,
    mean: n === 0 ? Number.NaN : total / n,
  };
}

/** Relative change from `before` to `after`, as a signed fraction. */
export function delta(before: number, after: number): number {
  if (before === 0) return Number.NaN;
  return (after - before) / before;
}

export function formatMs(value: number): string {
  if (Number.isNaN(value)) return '—';
  return value >= 100 ? value.toFixed(0) : value.toFixed(1);
}

export function formatDelta(fraction: number): string {
  if (Number.isNaN(fraction)) return '—';
  const percent = fraction * 100;
  const sign = percent > 0 ? '+' : '';
  return `${sign}${percent.toFixed(1)}%`;
}
