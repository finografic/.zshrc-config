import { describe, expect, it } from 'vitest';
import type { Edge } from './graph.js';

import { nodeId, renderMermaid } from './mermaid.js';

const edges: Edge[] = [
  { from: 'main.zsh', to: 'lib/colors.zsh', line: 1, via: 'source' },
  { from: 'profiles/d/d.zsh', to: 'lib/git.zsh', line: 0, via: 'manifest' },
];

describe('nodeId', () => {
  it('makes a path safe to use as a mermaid identifier', () => {
    expect(nodeId('lib/git/git.core.zsh')).toBe('lib_git_git_core_zsh');
  });
});

describe('renderMermaid', () => {
  it('emits a graph header', () => {
    expect(renderMermaid(edges)).toMatch(/^graph LR/);
  });

  it('distinguishes manifest edges with a dashed arrow', () => {
    const out = renderMermaid(edges);
    expect(out).toContain('main_zsh --> lib_colors_zsh');
    expect(out).toContain('profiles_d_d_zsh -.-> lib_git_zsh');
  });

  it('labels every node with its real path', () => {
    expect(renderMermaid(edges)).toContain('lib_colors_zsh["lib/colors.zsh"]');
  });

  it('de-duplicates repeated edges', () => {
    const repeated: Edge[] = [...edges, ...edges];
    const arrows = renderMermaid(repeated)
      .split('\n')
      .filter((l) => l.includes('-->'));
    expect(arrows).toHaveLength(1);
  });

  it('groups into subgraphs when asked', () => {
    const out = renderMermaid(edges, { grouped: true });
    expect(out).toContain('subgraph lib');
    expect(out).toContain('end');
  });
});
