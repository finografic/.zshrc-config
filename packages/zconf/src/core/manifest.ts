/**
 * Reads the profile-manifest system that `core/profile.zsh` implements, so
 * `doctor` validates against the real registry rather than a second copy of it
 * that would immediately drift.
 */

/** The registries declared in `core/profile.zsh`. */
export interface Registry {
  /** Module name -> repo-relative path. */
  readonly modulePaths: Record<string, string>;
  /** Canonical source order. */
  readonly moduleOrder: string[];
  /** Preset name -> module names it implies. */
  readonly presets: Record<string, string[]>;
}

/** What one profile's entry file declares. */
export interface Manifest {
  readonly preset: string | null;
  readonly modules: string[];
  readonly features: string[];
  readonly optIn: string[];
  readonly callsZenvLoad: boolean;
}

function parseAssocArray(content: string, name: string): Record<string, string> {
  const block = new RegExp(`typeset\\s+-g?A\\s+${name}=\\(([\\s\\S]*?)\\n\\)`, 'm').exec(content);
  const body = block?.[1] ?? '';
  const entries: Record<string, string> = {};

  // Values are either bare (`[git]=lib/git.zsh`) or quoted and multi-word
  // (`[full]="colors paths common"`).
  for (const match of body.matchAll(/\[([^\]]+)\]=(?:"([^"]*)"|(\S+))/g)) {
    const key = match[1];
    const value = match[2] ?? match[3];
    if (key !== undefined && value !== undefined) entries[key] = value;
  }

  return entries;
}

function parseIndexedArray(content: string, name: string): string[] {
  const block = new RegExp(`typeset\\s+-g?a\\s+${name}=\\(([\\s\\S]*?)\\n\\)`, 'm').exec(content);
  return splitWords(block?.[1] ?? '');
}

function splitWords(body: string): string[] {
  return body
    .split('\n')
    .map((line) => line.replace(/#.*$/, '').trim())
    .join(' ')
    .split(/\s+/)
    .filter((word) => word.length > 0);
}

/** Parses the `ZENV_*` registries out of `core/profile.zsh`. */
export function parseRegistry(content: string): Registry {
  const presets: Record<string, string[]> = {};
  for (const [name, value] of Object.entries(parseAssocArray(content, 'ZENV_PRESET_MODULES'))) {
    presets[name] = splitWords(value);
  }

  return {
    modulePaths: parseAssocArray(content, 'ZENV_MODULE_PATHS'),
    moduleOrder: parseIndexedArray(content, 'ZENV_MODULE_ORDER'),
    presets,
  };
}

function parseArrayAssignment(content: string, name: string): string[] {
  const match = new RegExp(`^\\s*${name}=\\(([^)]*)\\)`, 'm').exec(content);
  if (match === null) return [];
  return splitWords(match[1] ?? '');
}

/** Parses one profile entry file's manifest declarations. */
export function parseManifest(content: string): Manifest {
  const preset = /^\s*ZENV_PRESET=(\S+)/m.exec(content)?.[1] ?? null;

  return {
    preset: preset === null ? null : preset.replace(/['"]/g, ''),
    modules: parseArrayAssignment(content, 'ZENV_MODULES'),
    features: parseArrayAssignment(content, 'ZENV_FEATURES'),
    optIn: parseArrayAssignment(content, 'ZENV_OPT_IN'),
    callsZenvLoad: /^\s*zenv-load\s*$/m.test(content),
  };
}

/**
 * Resolves a manifest to the concrete repo-relative files it loads, in the
 * canonical order `zenv-modules` applies. Mirrors `zenv-load` + `zenv-modules`.
 */
export function resolveManifest(
  manifest: Manifest,
  registry: Registry,
  profileName: string,
): { readonly files: string[]; readonly unknownModules: string[] } {
  const presetModules = manifest.preset === null ? [] : (registry.presets[manifest.preset] ?? []);
  const requested = new Set([...presetModules, ...manifest.modules]);

  const files: string[] = [];
  const unknownModules: string[] = [];

  for (const name of requested) {
    if (registry.modulePaths[name] === undefined) unknownModules.push(name);
  }

  for (const name of registry.moduleOrder) {
    if (!requested.has(name)) continue;

    // `zenv-modules` wraps the `node` module in a mandatory boot sequence.
    // nvm first, then pnpm-path: pnpm-path's force-prepend of $PNPM_HOME/bin
    // must land in front of $NVM_BIN so pnpm's self-managed binary wins.
    if (name === 'node') {
      files.push('vendor/nvm.zsh', 'vendor/pnpm-path.zsh');
    }

    const path = registry.modulePaths[name];
    if (path !== undefined) files.push(path);
  }

  for (const feature of manifest.features) {
    files.push(`profiles/${profileName}/${profileName}.${feature}.zsh`);
  }

  for (const optIn of manifest.optIn) files.push(`extras/${optIn}.zsh`);

  return { files, unknownModules };
}
