import { describe, expect, it } from 'vitest';

import { parseManifest, parseRegistry, resolveManifest } from './manifest.js';

const REGISTRY_SOURCE = `
typeset -gA ZENV_MODULE_PATHS=(
	[colors]=lib/colors.zsh
	[git]=lib/git.zsh
	[node]=lib/node.zsh
	[disk]=lib/utils/disk.zsh
)

typeset -ga ZENV_MODULE_ORDER=(
	colors
	git
	node
	disk
)

typeset -gA ZENV_PRESET_MODULES=(
	[full]="colors git node"
	[minimal]="colors node"
	[none]=""
)
`;

describe('parseRegistry', () => {
  const registry = parseRegistry(REGISTRY_SOURCE);

  it('reads module name -> path', () => {
    expect(registry.modulePaths.git).toBe('lib/git.zsh');
    expect(registry.modulePaths.disk).toBe('lib/utils/disk.zsh');
  });

  it('reads the canonical order', () => {
    expect(registry.moduleOrder).toEqual(['colors', 'git', 'node', 'disk']);
  });

  it('reads multi-word quoted preset values', () => {
    expect(registry.presets.full).toEqual(['colors', 'git', 'node']);
    expect(registry.presets.none).toEqual([]);
  });
});

describe('parseManifest', () => {
  it('reads a full manifest', () => {
    const manifest = parseManifest(
      [
        'ZENV_PRESET=full',
        'ZENV_MODULES=(llms macos ghostty)',
        'ZENV_FEATURES=(backups aliases dev)',
        'ZENV_OPT_IN=(music/backup-dj-crate)',
        'zenv-load',
      ].join('\n'),
    );

    expect(manifest.preset).toBe('full');
    expect(manifest.modules).toEqual(['llms', 'macos', 'ghostty']);
    expect(manifest.features).toEqual(['backups', 'aliases', 'dev']);
    expect(manifest.optIn).toEqual(['music/backup-dj-crate']);
    expect(manifest.callsZenvLoad).toBe(true);
  });

  it('notices a profile that never calls zenv-load', () => {
    expect(parseManifest('ZENV_PRESET=none\n').callsZenvLoad).toBe(false);
  });

  it('defaults absent arrays to empty', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nzenv-load\n');
    expect(manifest.modules).toEqual([]);
    expect(manifest.optIn).toEqual([]);
  });
});

describe('resolveManifest', () => {
  const registry = parseRegistry(REGISTRY_SOURCE);

  it('applies the canonical order, not the declared order', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nZENV_MODULES=(disk git colors)\nzenv-load\n');
    const { files } = resolveManifest(manifest, registry, 'demo');
    expect(files).toEqual(['lib/colors.zsh', 'lib/git.zsh', 'lib/utils/disk.zsh']);
  });

  it('merges preset modules with the profile additions, de-duplicated', () => {
    const manifest = parseManifest('ZENV_PRESET=minimal\nZENV_MODULES=(colors git)\nzenv-load\n');
    const { files } = resolveManifest(manifest, registry, 'demo');
    expect(files.filter((f) => f === 'lib/colors.zsh')).toHaveLength(1);
    expect(files).toContain('lib/git.zsh');
  });

  it('injects the nvm/pnpm boot sequence around the node module', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nZENV_MODULES=(node)\nzenv-load\n');
    const { files } = resolveManifest(manifest, registry, 'demo');
    expect(files).toEqual(['vendor/nvm.zsh', 'vendor/pnpm-path.zsh', 'lib/node.zsh']);
  });

  it('resolves features to the profile-local path', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nZENV_FEATURES=(aliases)\nzenv-load\n');
    const { files } = resolveManifest(manifest, registry, 'home-macos');
    expect(files).toContain('profiles/home-macos/home-macos.aliases.zsh');
  });

  it('resolves opt-ins under extras/', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nZENV_OPT_IN=(music/x)\nzenv-load\n');
    const { files } = resolveManifest(manifest, registry, 'demo');
    expect(files).toContain('extras/music/x.zsh');
  });

  it('reports an unknown module name', () => {
    const manifest = parseManifest('ZENV_PRESET=none\nZENV_MODULES=(nope)\nzenv-load\n');
    expect(resolveManifest(manifest, registry, 'demo').unknownModules).toEqual(['nope']);
  });
});
