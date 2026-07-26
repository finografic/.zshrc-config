/**
 * The `doctor` rules: a static check of the load-model contract documented in
 * `docs/todo/TODO_PUBLIC_RELEASE_REFACTOR.md` and enforced at runtime by
 * `tests/test-lib-inert.zsh`.
 *
 * The two are complementary, not redundant. The zsh test proves inertness
 * empirically on the machine it runs on; these rules catch the same class of
 * mistake statically, including on code paths that only execute on another OS
 * (which is exactly how a `git clone` at source time in `lib/fzf.zsh` survived
 * an inertness sweep — the sweep runs on macOS, the bug was Linux-only).
 */

import type { Graph } from './graph.js';
import type { Registry } from './manifest.js';
import type { ParsedZsh } from './parse.js';

import { profileEntryPoints } from './graph.js';
import { parseManifest, resolveManifest } from './manifest.js';
import { isHardcodedRepoPath } from './parse.js';

/**
 * Third-party code we carry but do not author. Restyling it would only make
 * the next upstream update harder to diff.
 */
const VENDORED_PREFIXES = ['vendor/', 'themes/', 'scripts/.iterm2_shell_integration.zsh'];

/**
 * The trees that hold pure, sourced-only modules. `scripts/` is deliberately
 * absent: several of its files are legitimately dual-use (sourced for their
 * functions, executed for their CLI), so a shebang there is correct.
 */
const MODULE_PREFIXES = ['lib/', 'core/', 'bootstrap/', 'profiles/'];

function isVendored(file: string): boolean {
  return VENDORED_PREFIXES.some((prefix) => file.startsWith(prefix));
}

function isModuleTree(file: string): boolean {
  return MODULE_PREFIXES.some((prefix) => file.startsWith(prefix));
}

export type Severity = 'error' | 'warn';

export interface Finding {
  readonly rule: string;
  readonly severity: Severity;
  readonly file: string;
  readonly line: number;
  readonly message: string;
}

export interface RuleInput {
  readonly files: ReadonlyMap<string, ParsedZsh>;
  readonly contents: ReadonlyMap<string, string>;
  readonly trackedFiles: readonly string[];
  readonly registry: Registry;
  readonly graph: Graph;
  /**
   * True for paths git deliberately ignores. `core/env.zsh` sources
   * `$ZSHRC_ROOT/.env`, which is untracked by design and guarded by a `-f`
   * test — a missing-target report there would be noise, not a defect.
   */
  readonly isIgnored?: (path: string) => boolean;
}

/**
 * Statements that are safe at the top level of a sourced module: they define
 * or configure, they do not *do*.
 */
const INERT_HEADS = new Set([
  'source',
  '.',
  'export',
  'typeset',
  'declare',
  'local',
  'readonly',
  'alias',
  'unalias',
  'autoload',
  'zstyle',
  'zmodload',
  'setopt',
  'unsetopt',
  'bindkey',
  'compdef',
  'add-zsh-hook',
  'return',
  'fpath',
  'path',
  'umask',
  'if',
  'then',
  'elif',
  'else',
  'fi',
  'case',
  'esac',
  'for',
  'while',
  'do',
  'done',
  'function',
  '{',
  '}',
  ';;',
  '(',
  ')',
]);

/** Commands that unambiguously _do something_ when a file is merely sourced. */
const EFFECTFUL_HEADS = new Set([
  'echo',
  'print',
  'printf',
  'cat',
  'git',
  'curl',
  'wget',
  'brew',
  'npm',
  'pnpm',
  'yarn',
  'node',
  'mkdir',
  'rm',
  'cp',
  'mv',
  'touch',
  'ln',
  'chmod',
  'chown',
  'sudo',
  'eval',
  'defaults',
  'launchctl',
  'open',
  'osascript',
  'systemctl',
  'apt-get',
  'sed',
  'awk',
]);

function isAssignment(text: string): boolean {
  return /^[A-Za-z_][A-Za-z0-9_]*(\[[^\]]*\])?\+?=/.test(text);
}

function isGuardIdiom(text: string): boolean {
  // `(( ${+_X} )) && return 0` and friends.
  return /^\(\(.*\)\)\s*(&&|\|\|)\s*return\b/.test(text) || /^\(\(.*\)\)$/.test(text);
}

function isConditional(text: string): boolean {
  return text.startsWith('[[') || text.startsWith('((');
}

/**
 * Extracts the command a conditional guards, e.g.
 * `[[ -n "$X" ]] && export Y=1` -> `export Y=1`.
 */
function guardedCommand(text: string): string | null {
  const match = /^(?:\[\[.*?\]\]|\(\(.*?\)\))\s*(?:&&|\|\|)\s*(.+)$/.exec(text);
  const rest = match?.[1]?.trim() ?? null;
  if (rest === null) return null;
  return rest.replace(/^\{\s*/, '');
}

function headOf(text: string): string {
  return text.split(/\s+/)[0] ?? '';
}

/** `lib/` must be inert on source. */
export function libSideEffects(input: RuleInput): Finding[] {
  const findings: Finding[] = [];

  for (const [file, parsed] of input.files) {
    if (!file.startsWith('lib/')) continue;

    for (const statement of parsed.topLevel) {
      const inner = guardedCommand(statement.text);
      const effective = inner ?? statement.text;
      const head = inner === null ? statement.head : headOf(inner);

      if (EFFECTFUL_HEADS.has(head)) {
        findings.push({
          rule: 'lib-side-effect',
          severity: 'error',
          file,
          line: statement.line,
          message: `\`${head}\` runs when this file is sourced — move it into a function`,
        });
        continue;
      }

      // A command substitution spawns a process even inside an assignment.
      if (statement.hasCommandSubstitution && !isGuardIdiom(statement.text)) {
        findings.push({
          rule: 'lib-side-effect',
          severity: 'error',
          file,
          line: statement.line,
          message: 'command substitution spawns a process on every shell start',
        });
        continue;
      }

      if (
        isAssignment(effective) ||
        isGuardIdiom(statement.text) ||
        isConditional(statement.text) ||
        INERT_HEADS.has(head)
      ) {
        continue;
      }

      findings.push({
        rule: 'lib-side-effect',
        severity: 'warn',
        file,
        line: statement.line,
        message: `unrecognised top-level statement \`${head}\` — verify it is inert`,
      });
    }
  }

  return findings;
}

/** A `source` target that does not exist. */
export function brokenSources(input: RuleInput): Finding[] {
  const isIgnored = input.isIgnored ?? ((): boolean => false);

  return input.graph.broken
    .filter((entry) => !isIgnored(entry.target))
    .map((entry) => ({
      rule: 'broken-source',
      severity: 'error' as const,
      file: entry.from,
      line: entry.line,
      message: `sources \`${entry.target}\`, which does not exist`,
    }));
}

/** A tracked `.zsh` file that nothing loads. */
export function orphanModules(input: RuleInput): Finding[] {
  return input.graph.orphans
    .filter((path) => path.startsWith('lib/') || path.startsWith('core/') || path.startsWith('bootstrap/'))
    .map((path) => ({
      rule: 'orphan-module',
      severity: 'error' as const,
      file: path,
      line: 0,
      message: 'nothing sources this file — delete it or wire it up',
    }));
}

/** Every profile manifest must name known modules and existing features. */
export function manifestNames(input: RuleInput): Finding[] {
  const findings: Finding[] = [];

  for (const path of profileEntryPoints(input.files.keys())) {
    const name = path.split('/')[1] ?? '';
    const content = input.contents.get(path) ?? '';
    const manifest = parseManifest(content);

    if (!manifest.callsZenvLoad) {
      findings.push({
        rule: 'manifest',
        severity: 'error',
        file: path,
        line: 0,
        message: 'profile never calls `zenv-load`',
      });
      continue;
    }

    if (manifest.preset !== null && input.registry.presets[manifest.preset] === undefined) {
      findings.push({
        rule: 'manifest',
        severity: 'error',
        file: path,
        line: 0,
        message: `unknown preset \`${manifest.preset}\``,
      });
    }

    const { files: loaded, unknownModules } = resolveManifest(manifest, input.registry, name);

    for (const unknown of unknownModules) {
      findings.push({
        rule: 'manifest',
        severity: 'error',
        file: path,
        line: 0,
        message: `unknown module \`${unknown}\``,
      });
    }

    for (const target of loaded) {
      if (!input.files.has(target)) {
        findings.push({
          rule: 'manifest',
          severity: 'error',
          file: path,
          line: 0,
          message: `resolves to \`${target}\`, which does not exist`,
        });
      }
    }
  }

  return findings;
}

/** Every `lib/<domain>/` directory needs a `lib/<domain>.zsh` barrel. */
export function missingBarrels(input: RuleInput): Finding[] {
  const domains = new Set<string>();

  for (const path of input.files.keys()) {
    const match = /^lib\/([^/]+)\//.exec(path);
    const domain = match?.[1];
    if (domain !== undefined) domains.add(domain);
  }

  const findings: Finding[] = [];
  for (const domain of [...domains].sort()) {
    if (!input.files.has(`lib/${domain}.zsh`)) {
      findings.push({
        rule: 'missing-barrel',
        severity: 'error',
        file: `lib/${domain}/`,
        line: 0,
        message: `no barrel at lib/${domain}.zsh`,
      });
    }
  }

  return findings;
}

/**
 * Function naming: the `function` keyword, and kebab-case rather than
 * snake_case. A leading underscore is an established prefix in this repo
 * (`_ga`, `_gb`) and is not snake_case, so it is allowed.
 */
export function functionNaming(input: RuleInput): Finding[] {
  const findings: Finding[] = [];

  for (const [file, parsed] of input.files) {
    if (isVendored(file)) continue;

    for (const fn of parsed.functions) {
      if (!fn.usesFunctionKeyword) {
        findings.push({
          rule: 'function-style',
          severity: 'error',
          file,
          line: fn.line,
          message: `\`${fn.name}\` is missing the \`function\` keyword`,
        });
      }

      if (fn.name.replace(/^_+/, '').includes('_')) {
        findings.push({
          rule: 'function-style',
          severity: 'error',
          file,
          line: fn.line,
          message: `\`${fn.name}\` is snake_case — use kebab-case`,
        });
      }
    }
  }

  return findings;
}

/** A sourced module must not carry a shebang. */
export function shebangsInSourcedFiles(input: RuleInput): Finding[] {
  const findings: Finding[] = [];
  const sourced = new Set<string>();

  for (const edge of input.graph.edges) sourced.add(edge.to);

  for (const [file, parsed] of input.files) {
    if (!parsed.hasShebang || !sourced.has(file)) continue;
    if (!isModuleTree(file) || isVendored(file)) continue;
    findings.push({
      rule: 'shebang-in-sourced',
      severity: 'error',
      file,
      line: 1,
      message: 'sourced module carries a shebang — replace it with a `# NOTE:` header',
    });
  }

  return findings;
}

/** Two tracked `.zsh` files sharing a basename are a rename waiting to go wrong. */
export function duplicateBasenames(input: RuleInput): Finding[] {
  const byName = new Map<string, string[]>();

  for (const path of input.files.keys()) {
    const base = path.split('/').pop() ?? path;
    const list = byName.get(base) ?? [];
    list.push(path);
    byName.set(base, list);
  }

  const findings: Finding[] = [];
  for (const [base, paths] of [...byName.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
    if (paths.length < 2) continue;
    findings.push({
      rule: 'duplicate-basename',
      severity: 'warn',
      file: paths[0] ?? base,
      line: 0,
      message: `basename \`${base}\` is used by ${paths.length} files: ${paths.join(', ')}`,
    });
  }

  return findings;
}

/** A file inside this repo must be reached via `$ZSHRC_ROOT`, not `~/.zshrc-config`. */
export function hardcodedRepoPaths(input: RuleInput): Finding[] {
  const findings: Finding[] = [];

  for (const [file, parsed] of input.files) {
    if (isVendored(file)) continue;

    for (const ref of parsed.sources) {
      if (!isHardcodedRepoPath(ref.raw)) continue;
      findings.push({
        rule: 'hardcoded-repo-path',
        severity: 'error',
        file,
        line: ref.line,
        message: `sources \`${ref.raw}\` — use "$ZSHRC_ROOT/…" so the checkout can live anywhere`,
      });
    }
  }

  return findings;
}

const RULES = [
  brokenSources,
  orphanModules,
  hardcodedRepoPaths,
  libSideEffects,
  manifestNames,
  missingBarrels,
  functionNaming,
  shebangsInSourcedFiles,
  duplicateBasenames,
];

export function runAllRules(input: RuleInput): Finding[] {
  return RULES.flatMap((rule) => rule(input)).sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line);
}
