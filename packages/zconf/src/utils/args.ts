/** Minimal flag parsing — enough for this CLI, and testable. */

export interface ParsedArgs {
  /** The first non-flag argument. */
  readonly command: string;
  /** Remaining non-flag arguments, in order. */
  readonly positionals: string[];
  readonly flags: ReadonlySet<string>;
  /** `--key value` and `--key=value` pairs. */
  readonly options: ReadonlyMap<string, string>;
}

/** Flags that take a value, so `--zenv codex` does not read `codex` as a positional. */
const VALUE_FLAGS = new Set([
  '--profile',
  '--zenv',
  '--preset',
  '--features',
  '-n',
  '--runs',
  '--only',
  '--threshold',
]);

export function parseArgs(argv: readonly string[]): ParsedArgs {
  const positionals: string[] = [];
  const flags = new Set<string>();
  const options = new Map<string, string>();

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i] ?? '';

    if (!arg.startsWith('-')) {
      positionals.push(arg);
      continue;
    }

    const equals = arg.indexOf('=');
    if (equals !== -1) {
      options.set(arg.slice(0, equals), arg.slice(equals + 1));
      continue;
    }

    if (VALUE_FLAGS.has(arg)) {
      const next = argv[i + 1];
      if (next !== undefined && !next.startsWith('-')) {
        options.set(arg, next);
        i += 1;
        continue;
      }
    }

    flags.add(arg);
  }

  return {
    command: positionals[0] ?? 'help',
    positionals: positionals.slice(1),
    flags,
    options,
  };
}

export function numberOption(args: ParsedArgs, names: readonly string[], fallback: number): number {
  for (const name of names) {
    const raw = args.options.get(name);
    if (raw === undefined) continue;
    const value = Number(raw);
    if (Number.isFinite(value)) return value;
  }
  return fallback;
}

export function stringOption(args: ParsedArgs, names: readonly string[]): string | null {
  for (const name of names) {
    const value = args.options.get(name);
    if (value !== undefined) return value;
  }
  return null;
}
