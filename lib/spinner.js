'use strict';
const chalk = require('chalk');
const Ora = require('ora');

// ALL INCLUDED SPINNERS
// https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json

const spinner = new Ora({
  text: `${chalk.green('Starting ZSH:')} ${chalk.cyan.bold(
    `${process.env.ZENV.toUpperCase()} configuration...`
  )}`,
  indent: 0,
  color: 'cyan',
  spinner: 'bouncingBar',
  //spinner: process.argv[2]
});

spinner.start();

setTimeout(() => {
  spinner.succeed();
}, 600);
