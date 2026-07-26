import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { pc } from '../utils/picocolors.js';
import { loadRepo } from '../utils/repo.js';

export interface NewProfileOptions {
  readonly name: string;
  readonly preset: string;
  readonly features: string[];
  readonly dryRun: boolean;
}

const RULE = '# ============================================================================ #';

function entryTemplate(options: NewProfileOptions): string {
  const featureList = options.features.join(' ');

  return `${RULE}
# NOTE: ${options.name.toUpperCase()} - describe this host in one line
${RULE}

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/profiles/$ZENV"

${RULE}
# NOTE: MANIFEST
#
# Declare WHAT this host wants; core/profile.zsh works out HOW and in what
# order. Unknown names fail loudly rather than being skipped silently.
${RULE}

ZENV_PRESET=${options.preset}
ZENV_MODULES=()
ZENV_FEATURES=(${featureList})

zenv-load

${RULE}
# NOTE: PROFILE-SPECIFIC
#
# Anything needing a function the manifest just defined goes below zenv-load.
${RULE}
`;
}

function featureTemplate(name: string, feature: string): string {
  return `${RULE}
# NOTE: ${name.toUpperCase()} ${feature.toUpperCase()}
${RULE}

source "$ZSHRC_ROOT/lib/colors.zsh"
`;
}

export function newProfile(options: NewProfileOptions): number {
  const repo = loadRepo();

  if (!/^[a-z][a-z0-9-]*$/.test(options.name)) {
    console.error(pc.red(`invalid profile name: ${options.name}`));
    console.error(pc.gray('use lowercase kebab-case, e.g. work-linux'));
    return 1;
  }

  if (repo.registry.presets[options.preset] === undefined) {
    const known = Object.keys(repo.registry.presets).join(', ');
    console.error(pc.red(`unknown preset: ${options.preset}`));
    console.error(pc.gray(`known presets: ${known}`));
    return 1;
  }

  const dir = resolve(repo.root, 'profiles', options.name);
  if (existsSync(dir)) {
    console.error(pc.red(`profiles/${options.name}/ already exists`));
    return 1;
  }

  const files = new Map<string, string>();
  files.set(`profiles/${options.name}/${options.name}.zsh`, entryTemplate(options));
  for (const feature of options.features) {
    files.set(
      `profiles/${options.name}/${options.name}.${feature}.zsh`,
      featureTemplate(options.name, feature),
    );
  }

  if (options.dryRun) {
    console.log(pc.bold('would create:'));
    for (const path of files.keys()) console.log(`  ${path}`);
    console.log('');
    console.log(pc.gray('re-run without --dry-run to write them'));
    return 0;
  }

  mkdirSync(dir, { recursive: true });
  for (const [path, content] of files) writeFileSync(resolve(repo.root, path), content);

  console.log(pc.green(`✔ created profiles/${options.name}/`));
  for (const path of files.keys()) console.log(`  ${path}`);
  console.log('');
  console.log(pc.gray('next: teach core/detect.zsh when to select it, then run `zconf doctor`'));
  return 0;
}
