import { describe, expect, it } from 'vitest';

import { delta, formatDelta, formatMs, percentile, summarise } from './stats.js';

describe('percentile', () => {
  const sorted = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  it('uses nearest-rank, returning a value that was actually measured', () => {
    expect(percentile(sorted, 0.5)).toBe(50);
    expect(percentile(sorted, 0.95)).toBe(100);
  });

  it('handles a single sample', () => {
    expect(percentile([42], 0.95)).toBe(42);
  });

  it('returns NaN for no samples', () => {
    expect(percentile([], 0.5)).toBeNaN();
  });
});

describe('summarise', () => {
  it('summarises unsorted input', () => {
    const summary = summarise([30, 10, 20]);
    expect(summary).toMatchObject({ n: 3, min: 10, max: 30, p50: 20 });
    expect(summary.mean).toBeCloseTo(20);
  });

  it('does not mutate its input', () => {
    const samples = [3, 1, 2];
    summarise(samples);
    expect(samples).toEqual([3, 1, 2]);
  });

  it('handles an empty sample set without throwing', () => {
    expect(summarise([]).n).toBe(0);
  });
});

describe('delta', () => {
  it('reports a speedup as negative', () => {
    expect(delta(1000, 500)).toBeCloseTo(-0.5);
  });

  it('reports a regression as positive', () => {
    expect(delta(100, 150)).toBeCloseTo(0.5);
  });
});

describe('formatting', () => {
  it('drops decimals once a number is large enough not to need them', () => {
    expect(formatMs(563.34)).toBe('563');
    expect(formatMs(2.53)).toBe('2.5');
  });

  it('signs a delta', () => {
    expect(formatDelta(-0.65)).toBe('-65.0%');
    expect(formatDelta(0.12)).toBe('+12.0%');
  });

  it('renders an unknown value as a dash', () => {
    expect(formatMs(Number.NaN)).toBe('—');
    expect(formatDelta(Number.NaN)).toBe('—');
  });
});
