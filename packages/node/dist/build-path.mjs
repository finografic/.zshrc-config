#!/usr/bin/env tsx
import { existsSync } from "fs";

//#region src/build-path.ts
function getOptions() {
	return {
		validateExists: process.argv.includes("--validate"),
		verbose: process.argv.includes("--verbose")
	};
}
function buildPath(currentPath, options) {
	const paths = currentPath.split(":");
	const seen = /* @__PURE__ */ new Set();
	const result = [];
	const removed = [];
	const invalid = [];
	for (const p of paths) {
		if (!p) continue;
		if (seen.has(p)) {
			removed.push(p);
			continue;
		}
		if (options.validateExists && !existsSync(p)) {
			invalid.push(p);
			continue;
		}
		seen.add(p);
		result.push(p);
	}
	if (options.verbose) {
		if (removed.length > 0) console.error(`Removed ${removed.length} duplicate(s): ${removed.join(", ")}`);
		if (invalid.length > 0) console.error(`Removed ${invalid.length} invalid path(s): ${invalid.join(", ")}`);
	}
	return result.join(":");
}
function main() {
	const cleanPath = buildPath(process.env.PATH ?? "", getOptions());
	console.log(cleanPath);
}
main();

//#endregion
export {  };
//# sourceMappingURL=build-path.mjs.map