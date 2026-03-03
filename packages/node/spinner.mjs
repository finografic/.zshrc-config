import chalk from 'chalk';
import Ora from 'ora';

// REF: Spinner options: https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json

console.log(''); // add a new line

const zenv = process.env.ZENV?.toUpperCase() ?? 'DEFAULT';
const text = `${chalk.green('Initializing zsh:')} ${chalk.cyan.bold(`${zenv} configuration...`)}`;

const spinner = new Ora({ text, indent: 0, color: 'cyan', spinner: 'bouncingBar' });
spinner.start();

setTimeout(() => spinner.succeed(), 200);

console.log(''); // add a new line
