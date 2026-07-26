import { describe, expect, it } from 'vitest';

import { buildGraph, profileEntryPoints } from './graph.js';
import { parseRegistry } from './manifest.js';
import { parseZsh } from './parse.js';

const REGISTRY = parseRegistry(`
typeset -gA ZENV_MODULE_PATHS=(
	[colors]=lib/colors.zsh
	[git]=lib/git.zsh
)
typeset -ga ZENV_MODULE_ORDER=(
	colors
	git
)
typeset -gA ZENV_PRESET_MODULES=(
	[full]="colors git"
	[none]=""
)
`);

function makeInput(files: Record<string, string>, entryPoints: string[]): Parameters<typeof buildGraph>[0] {
  const contents = new Map(Object.entries(files));
  const parsed = new Map([...contents].map(([path, text]) => [path, parseZsh(text)]));
  return { files: parsed, contents, registry: REGISTRY, entryPoints };
}

describe('profileEntryPoints', () => {
  it('finds profiles/<name>/<name>.zsh only', () => {
    const paths = [
      'profiles/home-macos/home-macos.zsh',
      'profiles/home-macos/home-macos.dev.zsh',
      'lib/git.zsh',
    ];
    expect(profileEntryPoints(paths)).toEqual(['profiles/home-macos/home-macos.zsh']);
  });
});

describe('buildGraph', () => {
  it('records an edge for a resolvable source', () => {
    const graph = buildGraph(
      makeInput(
        {
          'main.zsh': 'source "$ZSHRC_ROOT/lib/colors.zsh"',
          'lib/colors.zsh': 'typeset -g _c="x"',
        },
        ['main.zsh'],
      ),
    );

    expect(graph.edges).toHaveLength(1);
    expect(graph.edges[0]).toMatchObject({ from: 'main.zsh', to: 'lib/colors.zsh', via: 'source' });
    expect(graph.orphans).toEqual([]);
  });

  it('reports a source target that does not exist', () => {
    const graph = buildGraph(makeInput({ 'main.zsh': 'source "$ZSHRC_ROOT/lib/gone.zsh"' }, ['main.zsh']));
    expect(graph.broken).toHaveLength(1);
    expect(graph.broken[0]?.target).toBe('lib/gone.zsh');
  });

  it('ignores a runtime-dependent target rather than calling it broken', () => {
    const graph = buildGraph(makeInput({ 'main.zsh': 'source "$ZENV_PATH/$ZENV.zsh"' }, ['main.zsh']));
    expect(graph.broken).toEqual([]);
  });

  it('reaches barrels through the manifest, not a literal source', () => {
    // The regression this guards: `zenv-modules` sources barrels via
    // ${ZENV_MODULE_PATHS[$name]}, so a graph built only from literal `source`
    // lines would declare every barrel an orphan.
    const graph = buildGraph(
      makeInput(
        {
          'profiles/demo/demo.zsh': 'ZENV_PRESET=full\nzenv-load\n',
          'lib/colors.zsh': 'typeset -g _c="x"',
          'lib/git.zsh': 'function g() { :; }',
        },
        [],
      ),
    );

    expect(graph.orphans).toEqual([]);
    expect(graph.edges.filter((e) => e.via === 'manifest')).toHaveLength(2);
  });

  it('reports a file nothing reaches', () => {
    const graph = buildGraph(
      makeInput({ 'main.zsh': 'print hi', 'lib/stray.zsh': 'function s() { :; }' }, ['main.zsh']),
    );
    expect(graph.orphans).toEqual(['lib/stray.zsh']);
  });

  it('follows edges transitively', () => {
    const graph = buildGraph(
      makeInput(
        {
          'main.zsh': 'source "$ZSHRC_ROOT/lib/a.zsh"',
          'lib/a.zsh': 'source "$ZSHRC_ROOT/lib/b.zsh"',
          'lib/b.zsh': 'typeset -g x=1',
        },
        ['main.zsh'],
      ),
    );
    expect(graph.orphans).toEqual([]);
    expect(graph.reachable.has('lib/b.zsh')).toBe(true);
  });

  it('does not loop forever on a source cycle', () => {
    const graph = buildGraph(
      makeInput(
        {
          'lib/a.zsh': 'source "$ZSHRC_ROOT/lib/b.zsh"',
          'lib/b.zsh': 'source "$ZSHRC_ROOT/lib/a.zsh"',
        },
        ['lib/a.zsh'],
      ),
    );
    expect(graph.reachable.size).toBe(2);
  });
});
