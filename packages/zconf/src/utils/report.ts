import type { Finding } from '../core/rules.js';

import { pc } from './picocolors.js';

export function formatLocation(file: string, line: number): string {
  return line > 0 ? `${file}:${line}` : file;
}

/** Groups findings by file and prints them, most severe first. */
export function printFindings(findings: readonly Finding[]): void {
  const byFile = new Map<string, Finding[]>();

  for (const finding of findings) {
    const list = byFile.get(finding.file) ?? [];
    list.push(finding);
    byFile.set(finding.file, list);
  }

  for (const [file, entries] of byFile) {
    console.log(pc.bold(file));
    for (const entry of entries) {
      const badge = entry.severity === 'error' ? pc.red('error') : pc.yellow('warn ');
      const where = entry.line > 0 ? pc.gray(`:${entry.line}`) : '';
      console.log(`  ${badge}${where} ${entry.message} ${pc.gray(`[${entry.rule}]`)}`);
    }
    console.log('');
  }
}

export function summariseFindings(findings: readonly Finding[]): {
  readonly errors: number;
  readonly warnings: number;
} {
  return {
    errors: findings.filter((f) => f.severity === 'error').length,
    warnings: findings.filter((f) => f.severity === 'warn').length,
  };
}
