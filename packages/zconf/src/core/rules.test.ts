import { describe, expect, it } from 'vitest';
import type { RuleInput } from './rules.js';

import { buildGraph } from './graph.js';
import { parseRegistry } from './manifest.js';
import { parseZsh } from './parse.js';
import {
  duplicateBasenames,
  functionNaming,
  hardcodedRepoPaths,
  libSideEffects,
  manifestNames,
  missingBarrels,
  runAllRules,
  shebangsInSourcedFiles,
} from './rules.js';

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

function makeInput(files: Record<string, string>, entryPoints: string[] = []): RuleInput {
  const contents = new Map(Object.entries(files));
  const parsed = new Map([...contents].map(([path, text]) => [path, parseZsh(text)]));
  const graph = buildGraph({ files: parsed, contents, registry: REGISTRY, entryPoints });

  return {
    files: parsed,
    contents,
    trackedFiles: [...contents.keys()],
    registry: REGISTRY,
    graph,
  };
}

describe('libSideEffects', () => {
  it('flags a top-level command', () => {
    const findings = libSideEffects(makeInput({ 'lib/a.zsh': 'echo hello' }));
    expect(findings).toHaveLength(1);
    expect(findings[0]?.severity).toBe('error');
  });

  it('flags a top-level command substitution even inside an assignment', () => {
    // The real case: `export CPATH=$(xcrun --show-sdk-path)/usr/include`
    // spawned a process on every shell start.
    const findings = libSideEffects(
      makeInput({ 'lib/a.zsh': 'export CPATH=$(xcrun --show-sdk-path)/usr/include' }),
    );
    expect(findings).toHaveLength(1);
  });

  it('flags a command hidden behind a conditional', () => {
    const findings = libSideEffects(makeInput({ 'lib/a.zsh': '[[ -d ~/.x ]] && git clone url ~/.x' }));
    expect(findings).toHaveLength(1);
  });

  it('accepts definitions, guards and assignments', () => {
    const content = [
      '(( ${+_ZSHRC_A_LOADED} )) && return 0',
      'typeset -g _ZSHRC_A_LOADED=1',
      'source "$ZSHRC_ROOT/lib/colors.zsh"',
      'export FOO=bar',
      'alias l="ls -lAh"',
      'autoload -Uz add-zsh-hook',
      'function thing() {',
      '  echo this is fine — it only runs when called',
      '}',
    ].join('\n');
    expect(libSideEffects(makeInput({ 'lib/a.zsh': content }))).toEqual([]);
  });

  it('accepts a single-quoted $(…) that defers to call time', () => {
    const findings = libSideEffects(makeInput({ 'lib/a.zsh': `alias lr='find "$(pwd)" -maxdepth 1'` }));
    expect(findings).toEqual([]);
  });

  it('ignores files outside lib/', () => {
    expect(libSideEffects(makeInput({ 'profiles/a/a.zsh': 'echo hi' }))).toEqual([]);
  });
});

describe('hardcodedRepoPaths', () => {
  it('flags a ~/.zshrc-config source', () => {
    const findings = hardcodedRepoPaths(
      makeInput({ 'extras/a.zsh': 'source ~/.zshrc-config/lib/colors.zsh' }),
    );
    expect(findings).toHaveLength(1);
  });

  it('accepts the ZSHRC_ROOT fallback form', () => {
    const findings = hardcodedRepoPaths(
      makeInput({ 'extras/a.zsh': 'source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"' }),
    );
    expect(findings).toEqual([]);
  });
});

describe('functionNaming', () => {
  it('flags a missing function keyword', () => {
    const findings = functionNaming(makeInput({ 'lib/a.zsh': 'thing() {\n}' }));
    expect(findings.map((f) => f.message)).toContain('`thing` is missing the `function` keyword');
  });

  it('flags snake_case', () => {
    const findings = functionNaming(makeInput({ 'lib/a.zsh': 'function my_thing() {\n}' }));
    expect(findings.some((f) => f.message.includes('snake_case'))).toBe(true);
  });

  it('allows the leading-underscore prefix convention', () => {
    expect(functionNaming(makeInput({ 'lib/a.zsh': 'function _gb() {\n}' }))).toEqual([]);
  });

  it('leaves vendored code alone', () => {
    expect(functionNaming(makeInput({ 'vendor/nvm.zsh': 'nvm_find_nvmrc() {\n}' }))).toEqual([]);
  });
});

describe('shebangsInSourcedFiles', () => {
  it('flags a shebang in a sourced module', () => {
    const findings = shebangsInSourcedFiles(
      makeInput({ 'main.zsh': 'source "$ZSHRC_ROOT/lib/a.zsh"', 'lib/a.zsh': '#!/bin/zsh\ntypeset -g x=1' }, [
        'main.zsh',
      ]),
    );
    expect(findings).toHaveLength(1);
  });

  it('allows a shebang in a dual-use script', () => {
    const findings = shebangsInSourcedFiles(
      makeInput(
        {
          'main.zsh': 'source "$ZSHRC_ROOT/scripts/a.zsh"',
          'scripts/a.zsh': '#!/bin/zsh\ntypeset -g x=1',
        },
        ['main.zsh'],
      ),
    );
    expect(findings).toEqual([]);
  });

  it('allows a shebang in a file nothing sources', () => {
    expect(shebangsInSourcedFiles(makeInput({ 'scripts/a.zsh': '#!/bin/zsh\nprint hi' }))).toEqual([]);
  });
});

describe('missingBarrels', () => {
  it('flags a lib subdirectory with no barrel', () => {
    const findings = missingBarrels(makeInput({ 'lib/thing/thing.core.zsh': 'typeset -g x=1' }));
    expect(findings).toHaveLength(1);
    expect(findings[0]?.message).toContain('lib/thing.zsh');
  });

  it('accepts a subdirectory that has one', () => {
    const findings = missingBarrels(
      makeInput({ 'lib/thing.zsh': 'typeset -g x=1', 'lib/thing/thing.core.zsh': 'typeset -g y=1' }),
    );
    expect(findings).toEqual([]);
  });
});

describe('manifestNames', () => {
  it('flags an unknown module', () => {
    const findings = manifestNames(
      makeInput({ 'profiles/d/d.zsh': 'ZENV_PRESET=none\nZENV_MODULES=(nope)\nzenv-load\n' }),
    );
    expect(findings.some((f) => f.message.includes('unknown module'))).toBe(true);
  });

  it('flags an unknown preset', () => {
    const findings = manifestNames(makeInput({ 'profiles/d/d.zsh': 'ZENV_PRESET=enormous\nzenv-load\n' }));
    expect(findings.some((f) => f.message.includes('unknown preset'))).toBe(true);
  });

  it('flags a profile that never calls zenv-load', () => {
    const findings = manifestNames(makeInput({ 'profiles/d/d.zsh': 'ZENV_PRESET=none\n' }));
    expect(findings.some((f) => f.message.includes('zenv-load'))).toBe(true);
  });

  it('flags a feature whose file is missing', () => {
    const findings = manifestNames(
      makeInput({ 'profiles/d/d.zsh': 'ZENV_PRESET=none\nZENV_FEATURES=(gone)\nzenv-load\n' }),
    );
    expect(findings.some((f) => f.message.includes('profiles/d/d.gone.zsh'))).toBe(true);
  });

  it('accepts a valid manifest', () => {
    const findings = manifestNames(
      makeInput({
        'profiles/d/d.zsh': 'ZENV_PRESET=none\nZENV_MODULES=(colors)\nZENV_FEATURES=(dev)\nzenv-load\n',
        'profiles/d/d.dev.zsh': 'typeset -g x=1',
        'lib/colors.zsh': 'typeset -g _c="x"',
      }),
    );
    expect(findings).toEqual([]);
  });
});

describe('duplicateBasenames', () => {
  it('warns when two files share a basename', () => {
    const findings = duplicateBasenames(makeInput({ 'lib/a/index.zsh': 'x=1', 'lib/b/index.zsh': 'y=1' }));
    expect(findings).toHaveLength(1);
    expect(findings[0]?.severity).toBe('warn');
  });
});

describe('runAllRules', () => {
  it('returns findings sorted by file then line', () => {
    const findings = runAllRules(makeInput({ 'lib/b.zsh': 'echo two', 'lib/a.zsh': 'echo one' }));
    const files = findings.map((f) => f.file);
    expect(files).toEqual([...files].sort());
  });

  it('is silent on a well-formed repo', () => {
    const findings = runAllRules(
      makeInput(
        {
          'main.zsh': 'source "$ZSHRC_ROOT/lib/colors.zsh"',
          'lib/colors.zsh': 'typeset -g _c="x"',
          'lib/git.zsh': 'function g() {\n  echo ok\n}',
          'profiles/d/d.zsh': 'ZENV_PRESET=full\nzenv-load\n',
        },
        ['main.zsh'],
      ),
    );
    expect(findings).toEqual([]);
  });
});
