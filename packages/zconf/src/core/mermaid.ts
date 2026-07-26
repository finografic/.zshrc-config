/** Renders the load graph as a mermaid diagram for `docs/ARCHITECTURE.md`. */

import type { Edge } from './graph.js';

/** Mermaid node ids must be identifier-safe; paths are not. */
export function nodeId(path: string): string {
  return path.replace(/[^A-Za-z0-9]/g, '_');
}

function layerOf(path: string): string {
  const top = path.split('/')[0] ?? path;
  if (path === '.zshrc') return 'entry';
  if (top === 'main.zsh' || top === 'main-splash.zsh') return 'entry';
  return top;
}

export interface MermaidOptions {
  /** Group nodes into subgraphs by top-level directory. */
  readonly grouped?: boolean;
  readonly direction?: 'TD' | 'LR';
}

export function renderMermaid(edges: readonly Edge[], options: MermaidOptions = {}): string {
  const direction = options.direction ?? 'LR';
  const lines: string[] = [`graph ${direction}`];

  const nodes = new Set<string>();
  for (const edge of edges) {
    nodes.add(edge.from);
    nodes.add(edge.to);
  }

  if (options.grouped === true) {
    const byLayer = new Map<string, string[]>();
    for (const node of [...nodes].sort()) {
      const layer = layerOf(node);
      const list = byLayer.get(layer) ?? [];
      list.push(node);
      byLayer.set(layer, list);
    }

    for (const [layer, members] of [...byLayer.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
      lines.push(`  subgraph ${layer}`);
      for (const member of members) lines.push(`    ${nodeId(member)}["${member}"]`);
      lines.push('  end');
    }
  } else {
    for (const node of [...nodes].sort()) lines.push(`  ${nodeId(node)}["${node}"]`);
  }

  const seen = new Set<string>();
  for (const edge of edges) {
    const key = `${edge.from}->${edge.to}`;
    if (seen.has(key)) continue;
    seen.add(key);
    // A dashed edge is one the manifest establishes, with no literal `source`.
    const arrow = edge.via === 'manifest' ? '-.->' : '-->';
    lines.push(`  ${nodeId(edge.from)} ${arrow} ${nodeId(edge.to)}`);
  }

  return lines.join('\n');
}
