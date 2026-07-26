import { describe, expect, it } from 'vitest';

import { compareToBaseline, parseBenchJson, regressions, renderComparison } from './bench.js';

const SAMPLE = JSON.stringify({
  date: '2026-07-26',
  runs: 20,
  host: 'Darwin arm64',
  profiles: {
    'home-macos': { min_ms: 528.4, p50_ms: 547.4, p95_ms: 568.4 },
    'codex': { min_ms: 54.9, p50_ms: 55.8, p95_ms: 61.2 },
  },
});

describe('parseBenchJson', () => {
  it('reads the shape bench-startup.zsh writes', () => {
    const baseline = parseBenchJson(SAMPLE);
    expect(baseline.runs).toBe(20);
    expect(baseline.host).toBe('Darwin arm64');
    expect(baseline.profiles.codex).toEqual({ min: 54.9, p50: 55.8, p95: 61.2 });
  });

  it('drops a malformed profile entry rather than throwing', () => {
    const text = JSON.stringify({ profiles: { good: { min_ms: 1, p50_ms: 2, p95_ms: 3 }, bad: 7 } });
    expect(Object.keys(parseBenchJson(text).profiles)).toEqual(['good']);
  });

  it('tolerates missing metadata', () => {
    expect(parseBenchJson('{}').profiles).toEqual({});
  });
});

describe('compareToBaseline', () => {
  const baseline = { a: { min: 100, p50: 100, p95: 100 } };

  it('reports a speedup as a negative change', () => {
    const rows = compareToBaseline({ a: { min: 50, p50: 50, p95: 50 } }, baseline);
    expect(rows[0]?.change).toBeCloseTo(-0.5);
  });

  it('reports a regression as a positive change', () => {
    const rows = compareToBaseline({ a: { min: 150, p50: 150, p95: 150 } }, baseline);
    expect(rows[0]?.change).toBeCloseTo(0.5);
  });

  it('lists a profile missing from the current run', () => {
    const rows = compareToBaseline({}, baseline);
    expect(rows[0]).toMatchObject({ profile: 'a', current: null });
    expect(rows[0]?.change).toBeNaN();
  });

  it('lists a profile that has no baseline yet', () => {
    const rows = compareToBaseline({ b: { min: 1, p50: 1, p95: 1 } }, {});
    expect(rows[0]).toMatchObject({ profile: 'b', baseline: null });
  });

  it('sorts rows by profile name', () => {
    const rows = compareToBaseline({ z: { min: 1, p50: 1, p95: 1 }, a: { min: 1, p50: 1, p95: 1 } }, {});
    expect(rows.map((r) => r.profile)).toEqual(['a', 'z']);
  });
});

describe('regressions', () => {
  it('flags only changes beyond the threshold', () => {
    const rows = compareToBaseline(
      { slow: { min: 130, p50: 130, p95: 130 }, same: { min: 101, p50: 101, p95: 101 } },
      { slow: { min: 100, p50: 100, p95: 100 }, same: { min: 100, p50: 100, p95: 100 } },
    );
    expect(regressions(rows, 0.2).map((r) => r.profile)).toEqual(['slow']);
  });

  it('never flags a row with no baseline', () => {
    const rows = compareToBaseline({ b: { min: 999, p50: 999, p95: 999 } }, {});
    expect(regressions(rows, 0.01)).toEqual([]);
  });
});

describe('renderComparison', () => {
  it('renders a header and one row per profile', () => {
    const rows = compareToBaseline(
      { a: { min: 50, p50: 50, p95: 50 } },
      { a: { min: 100, p50: 100, p95: 100 } },
    );
    const table = renderComparison(rows).split('\n');
    expect(table[0]).toContain('PROFILE');
    expect(table[1]).toContain('a');
    expect(table[1]).toContain('-50.0%');
  });

  it('renders a dash for a profile with no current timing', () => {
    const rows = compareToBaseline({}, { a: { min: 1, p50: 1, p95: 1 } });
    expect(renderComparison(rows)).toContain('—');
  });
});
