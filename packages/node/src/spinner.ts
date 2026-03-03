#!/usr/bin/env tsx
// ============================================================================
// SPINNER - Visual loading indicator for zshrc-config bootstrap
// ============================================================================
// REF: Spinner options: https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json
// ============================================================================

import chalk from 'chalk';
import ora from 'ora';
import type { ZEnv } from './types.js';

const SPINNER_DURATION_MS = 200;

function getSpinnerText(zenv: ZEnv | string): string {
  const envDisplay = zenv.toUpperCase();
  return `${chalk.green('Initializing zsh:')} ${chalk.cyan.bold(`${envDisplay} configuration...`)}`;
}

async function main(): Promise<void> {
  const zenv = (process.env.ZENV as ZEnv) ?? 'default';

  console.log(''); // Add newline before spinner

  const spinner = ora({
    text: getSpinnerText(zenv),
    indent: 0,
    color: 'cyan',
    spinner: 'bouncingBar',
  });

  spinner.start();

  await new Promise<void>((resolve) => {
    setTimeout(() => {
      spinner.succeed();
      resolve();
    }, SPINNER_DURATION_MS);
  });
}

main();
