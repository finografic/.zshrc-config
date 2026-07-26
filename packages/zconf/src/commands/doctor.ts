import { buildGraph } from '../core/graph.js';
import { runAllRules } from '../core/rules.js';
import { pc } from '../utils/picocolors.js';
import { ENTRY_POINTS, loadRepo, makeIsIgnored } from '../utils/repo.js';
import { printFindings, summariseFindings } from '../utils/report.js';

export interface DoctorOptions {
  /** Treat warnings as failures too. */
  readonly strict: boolean;
}

export function doctor(options: DoctorOptions): number {
  const repo = loadRepo();
  const graph = buildGraph({
    files: repo.parsed,
    contents: repo.contents,
    registry: repo.registry,
    entryPoints: [...ENTRY_POINTS],
  });

  const findings = runAllRules({
    files: repo.parsed,
    contents: repo.contents,
    trackedFiles: repo.trackedFiles,
    registry: repo.registry,
    graph,
    isIgnored: makeIsIgnored(repo.root),
  });

  if (findings.length > 0) printFindings(findings);

  const { errors, warnings } = summariseFindings(findings);
  const scanned = `${repo.parsed.size} zsh files, ${graph.edges.length} load edges`;

  if (errors === 0 && warnings === 0) {
    console.log(pc.green(`✔ doctor: clean (${scanned})`));
    return 0;
  }

  const parts: string[] = [];
  if (errors > 0) parts.push(pc.red(`${errors} error${errors === 1 ? '' : 's'}`));
  if (warnings > 0) parts.push(pc.yellow(`${warnings} warning${warnings === 1 ? '' : 's'}`));
  console.log(`${parts.join(', ')} ${pc.gray(`(${scanned})`)}`);

  if (errors > 0) return 1;
  return options.strict ? 1 : 0;
}
