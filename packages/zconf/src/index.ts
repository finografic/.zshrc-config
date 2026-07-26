/**
 * `zconf` — the maintainer CLI for zshrc-config.
 *
 * Scope rule (Phase 5 of the refactor plan): anything that must run on every
 * shell, or on a machine where Node may not exist, stays pure zsh. This CLI is
 * only ever invoked deliberately — by a maintainer, by CI, or by a git hook.
 */

import { pc } from './utils/picocolors.js';

import { doctor } from './commands/doctor.js';
import { scan } from './commands/scan.js';

const USAGE = `${pc.bold('zconf')} — maintainer CLI for zshrc-config

${pc.bold('Usage')}
  zconf <command> [options]

${pc.bold('Commands')}
  doctor              Lint the repo against the load-model contract
  scan                Scan tracked files for secrets and PII
  help                Show this message

${pc.bold('Options')}
  --strict            doctor: treat warnings as failures
  -h, --help          Show this message
`;

export function run(argv: readonly string[]): number {
  const args = [...argv];
  const command = args.find((arg) => !arg.startsWith('-')) ?? 'help';
  const flags = new Set(args.filter((arg) => arg.startsWith('-')));

  if (flags.has('-h') || flags.has('--help') || command === 'help') {
    console.log(USAGE);
    return 0;
  }

  switch (command) {
    case 'doctor':
      return doctor({ strict: flags.has('--strict') });
    case 'scan':
      return scan();
    default:
      console.error(pc.red(`unknown command: ${command}`));
      console.error(USAGE);
      return 2;
  }
}

process.exitCode = run(process.argv.slice(2));
