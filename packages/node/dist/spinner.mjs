#!/usr/bin/env tsx
import chalk from "chalk";
import ora from "ora";

//#region src/spinner.ts
const SPINNER_DURATION_MS = 200;
function getSpinnerText(zenv) {
	const envDisplay = zenv.toUpperCase();
	return `${chalk.green("Initializing zsh:")} ${chalk.cyan.bold(`${envDisplay} configuration...`)}`;
}
async function main() {
	const zenv = process.env.ZENV ?? "default";
	console.log("");
	const spinner = ora({
		text: getSpinnerText(zenv),
		indent: 0,
		color: "cyan",
		spinner: "bouncingBar"
	});
	spinner.start();
	await new Promise((resolve) => {
		setTimeout(() => {
			spinner.succeed();
			resolve();
		}, SPINNER_DURATION_MS);
	});
}
main();

//#endregion
export {  };
//# sourceMappingURL=spinner.mjs.map