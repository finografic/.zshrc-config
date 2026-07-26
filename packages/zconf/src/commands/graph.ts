import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { buildGraph, profileEntryPoints } from '../core/graph.js';
import { parseManifest, resolveManifest } from '../core/manifest.js';
import { renderMermaid } from '../core/mermaid.js';
import { pc } from '../utils/picocolors.js';
import { ENTRY_POINTS, loadRepo } from '../utils/repo.js';

export interface GraphOptions {
  /** Render one profile's resolved load order instead of the whole graph. */
  readonly profile: string | null;
  /** Write the diagram into docs/ARCHITECTURE.md between its markers. */
  readonly write: boolean;
  readonly grouped: boolean;
}

const MARKER_START = '<!-- zconf:graph:start -->';
const MARKER_END = '<!-- zconf:graph:end -->';

function renderProfileOrder(repoRoot: string, profile: string): string | null {
  const repo = loadRepo(repoRoot);
  const entry = `profiles/${profile}/${profile}.zsh`;
  const content = repo.contents.get(entry);

  if (content === undefined) return null;

  const { files } = resolveManifest(parseManifest(content), repo.registry, profile);
  const lines = [`${pc.bold(profile)} resolved load order:`, ''];

  files.forEach((file, index) => {
    const exists = repo.contents.has(file);
    const marker = exists ? pc.green('✔') : pc.red('✖');
    lines.push(`  ${marker} ${String(index + 1).padStart(2)}. ${file}`);
  });

  return lines.join('\n');
}

export function graph(options: GraphOptions): number {
  const repo = loadRepo();

  if (options.profile !== null) {
    const rendered = renderProfileOrder(repo.root, options.profile);
    if (rendered === null) {
      const known = profileEntryPoints(repo.contents.keys())
        .map((path) => path.split('/')[1] ?? '')
        .join(', ');
      console.error(pc.red(`unknown profile: ${options.profile}`));
      console.error(pc.gray(`known profiles: ${known}`));
      return 1;
    }
    console.log(rendered);
    return 0;
  }

  const built = buildGraph({
    files: repo.parsed,
    contents: repo.contents,
    registry: repo.registry,
    entryPoints: [...ENTRY_POINTS],
  });

  const diagram = renderMermaid(built.edges, { grouped: options.grouped });

  if (!options.write) {
    console.log(diagram);
    return 0;
  }

  const docPath = resolve(repo.root, 'docs/ARCHITECTURE.md');
  let doc: string;
  try {
    doc = readFileSync(docPath, 'utf8');
  } catch {
    console.error(pc.red('docs/ARCHITECTURE.md does not exist yet'));
    console.error(pc.gray(`add the markers ${MARKER_START} / ${MARKER_END} to it first`));
    return 1;
  }

  const start = doc.indexOf(MARKER_START);
  const end = doc.indexOf(MARKER_END);

  if (start === -1 || end === -1 || end < start) {
    console.error(pc.red(`docs/ARCHITECTURE.md is missing the ${MARKER_START} / ${MARKER_END} markers`));
    return 1;
  }

  const updated =
    doc.slice(0, start + MARKER_START.length) + `\n\n\`\`\`mermaid\n${diagram}\n\`\`\`\n\n` + doc.slice(end);

  if (updated === doc) {
    console.log(pc.green('✔ graph: docs/ARCHITECTURE.md already up to date'));
    return 0;
  }

  writeFileSync(docPath, updated);
  console.log(pc.green(`✔ graph: wrote ${built.edges.length} edges into docs/ARCHITECTURE.md`));
  return 0;
}
