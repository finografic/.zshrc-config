/**
 * The load graph.
 *
 * The subtlety worth stating: literal `source` lines are only half the story.
 * `zenv-modules` sources barrels through `${ZENV_MODULE_PATHS[$name]}`, and
 * `zenv-features` through `$ZENV_PATH/$ZENV.<name>.zsh` — both invisible to a
 * grep for `source`. A reachability check that ignored them would declare every
 * barrel an orphan. So the graph is seeded from the entry points AND from each
 * profile's resolved manifest.
 */

import type { Registry } from './manifest.js';
import type { ParsedZsh } from './parse.js';

import { parseManifest, resolveManifest } from './manifest.js';

export interface GraphInput {
  /** Repo-relative path -> parsed contents, for every tracked `.zsh` file. */
  readonly files: ReadonlyMap<string, ParsedZsh>;
  /** Raw contents, needed to read profile manifests. */
  readonly contents: ReadonlyMap<string, string>;
  readonly registry: Registry;
  /** Repo-relative paths that are loaded by the shell itself, not by a source. */
  readonly entryPoints: string[];
}

export interface Edge {
  readonly from: string;
  readonly to: string;
  readonly line: number;
  /** How the edge was established. */
  readonly via: 'source' | 'manifest';
}

export interface BrokenSource {
  readonly from: string;
  readonly target: string;
  readonly line: number;
}

export interface Graph {
  readonly edges: Edge[];
  readonly broken: BrokenSource[];
  /** Every file reachable from an entry point. */
  readonly reachable: ReadonlySet<string>;
  /** Files that exist but nothing loads. */
  readonly orphans: string[];
}

/** Profile entry files: `profiles/<name>/<name>.zsh`. */
export function profileEntryPoints(paths: Iterable<string>): string[] {
  const entries: string[] = [];
  for (const path of paths) {
    const match = /^profiles\/([^/]+)\/([^/]+)\.zsh$/.exec(path);
    if (match !== null && match[1] === match[2]) entries.push(path);
  }
  return entries.sort();
}

export function buildGraph(input: GraphInput): Graph {
  const { files, contents, registry } = input;
  const edges: Edge[] = [];
  const broken: BrokenSource[] = [];

  for (const [path, parsed] of files) {
    for (const ref of parsed.sources) {
      if (ref.resolved === null) continue;
      if (files.has(ref.resolved)) {
        edges.push({ from: path, to: ref.resolved, line: ref.line, via: 'source' });
      } else {
        broken.push({ from: path, target: ref.resolved, line: ref.line });
      }
    }
  }

  // Manifest-driven edges, which no `source` line spells out.
  for (const path of profileEntryPoints(files.keys())) {
    const name = path.split('/')[1] ?? '';
    const content = contents.get(path) ?? '';
    const { files: loaded } = resolveManifest(parseManifest(content), registry, name);

    for (const target of loaded) {
      if (files.has(target)) edges.push({ from: path, to: target, line: 0, via: 'manifest' });
    }
  }

  const adjacency = new Map<string, string[]>();
  for (const edge of edges) {
    const list = adjacency.get(edge.from) ?? [];
    list.push(edge.to);
    adjacency.set(edge.from, list);
  }

  const reachable = new Set<string>();
  const queue = [...input.entryPoints, ...profileEntryPoints(files.keys())];

  while (queue.length > 0) {
    const current = queue.pop();
    if (current === undefined || reachable.has(current)) continue;
    reachable.add(current);
    for (const next of adjacency.get(current) ?? []) queue.push(next);
  }

  const orphans = [...files.keys()].filter((path) => !reachable.has(path)).sort();

  return { edges, broken, reachable, orphans };
}
