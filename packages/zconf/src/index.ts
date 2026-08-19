/**
 * `zconf` — the maintainer CLI for zshrc-config.
 *
 * Scope rule (Phase 5 of the refactor plan): anything that must run on every
 * shell, or on a machine where Node may not exist, stays pure zsh. This CLI is
 * only ever invoked deliberately — by a maintainer, by CI, or by a git hook.
 */

import type { ParsedArgs } from './utils/args.js';
import { numberOption, parseArgs, stringOption } from './utils/args.js';
import { pc } from './utils/picocolors.js';

import { bench } from './commands/bench.js';
import { doctor } from './commands/doctor.js';
import { graph } from './commands/graph.js';
import { message } from './commands/message.js';
import { newProfile } from './commands/newProfile.js';
import { normalize } from './commands/normalize.js';
import { scan } from './commands/scan.js';

const USAGE = `${pc.bold('zconf')} — maintainer CLI for zshrc-config

${pc.bold('Usage')}
  zconf <command> [options]

${pc.bold('Commands')}
  doctor                    Lint the repo against the load-model contract
  scan                      Scan tracked files for secrets and PII
  graph                     Emit the load graph as mermaid
  bench                     Measure startup and diff against the baseline
  normalize                 Normalise comment blocks and function style
  new-profile <name>        Scaffold a new profile from templates
  message                   Generate a commit message from the pending diff (Ollama)
  help                      Show this message

${pc.bold('Options')}
  --strict                  doctor: treat warnings as failures
  --staged                  message: diff staged changes only, not all tracked changes
  --profile <name>          graph/bench: restrict to one profile
  --write                   graph: write into docs/ARCHITECTURE.md
  --grouped                 graph: group nodes into subgraphs by directory
  -n, --runs <n>            bench: shells per profile (default 10)
  --threshold <fraction>    bench: regression threshold (default 0.2)
  --only <comments|functions>  normalize: run a single pass
  --preset <name>           new-profile: preset (default minimal)
  --features <a,b>          new-profile: comma-separated feature files
  --dry-run                 normalize/new-profile: change nothing
  -h, --help                Show this message
`;

function normalizeOnly(args: ParsedArgs): 'comments' | 'functions' | null {
  const value = stringOption(args, ['--only']);
  if (value === 'comments' || value === 'functions') return value;
  return null;
}

export async function run(argv: readonly string[]): Promise<number> {
  const args = parseArgs(argv);

  if (args.flags.has('-h') || args.flags.has('--help') || args.command === 'help') {
    console.log(USAGE);
    return 0;
  }

  const dryRun = args.flags.has('--dry-run');

  switch (args.command) {
    case 'doctor':
      return doctor({ strict: args.flags.has('--strict') });

    case 'scan':
      return scan();

    case 'message':
      return message({ staged: args.flags.has('--staged') });

    case 'graph':
      return graph({
        profile: stringOption(args, ['--profile', '--zenv']),
        write: args.flags.has('--write'),
        grouped: args.flags.has('--grouped'),
      });

    case 'bench':
      return bench({
        runs: numberOption(args, ['-n', '--runs'], 10),
        profile: stringOption(args, ['--profile', '--zenv']),
        threshold: numberOption(args, ['--threshold'], 0.2),
      });

    case 'normalize':
      return normalize({ dryRun, only: normalizeOnly(args) });

    case 'new-profile': {
      const name = args.positionals[0];
      if (name === undefined) {
        console.error(pc.red('new-profile needs a name, e.g. `zconf new-profile work-linux`'));
        return 2;
      }
      const features = stringOption(args, ['--features']);
      return newProfile({
        name,
        preset: stringOption(args, ['--preset']) ?? 'minimal',
        features: features === null ? [] : features.split(',').filter(Boolean),
        dryRun,
      });
    }

    default:
      console.error(pc.red(`unknown command: ${args.command}`));
      console.error(USAGE);
      return 2;
  }
}

process.exitCode = await run(process.argv.slice(2));
