#!/usr/bin/env tsx
import { execSync } from "child_process";

//#region src/types.ts
const KNOWN_IPS = {
	APNAES: "REDACTED-IP",
	OFFICE: "REDACTED-IP",
	HOME: "REDACTED-IP"
};

//#endregion
//#region src/detect-env.ts
function detectOS() {
	const platform = process.platform;
	const arch = process.arch === "arm64" ? "arm64" : "x86_64";
	const hostname = execSync("hostname", { encoding: "utf-8" }).trim();
	if (platform === "darwin") return {
		osName: "macOS",
		osVersion: execSync("sw_vers -productVersion", { encoding: "utf-8" }).trim(),
		osBuild: execSync("sw_vers -buildVersion", { encoding: "utf-8" }).trim(),
		arch,
		hostname
	};
	else if (platform === "linux") {
		const osVersion = execSync("uname -v", { encoding: "utf-8" }).trim();
		const osKernel = execSync("uname -r", { encoding: "utf-8" }).trim();
		return {
			osName: process.env.ANDROID_ROOT !== void 0 || process.env.TERMUX_VERSION !== void 0 ? "Android" : "Linux",
			osVersion,
			osKernel,
			arch,
			hostname
		};
	} else if (platform === "win32") return {
		osName: "Windows",
		osVersion: process.version,
		arch,
		hostname
	};
	return {
		osName: "Unknown",
		osVersion: "unknown",
		arch,
		hostname
	};
}
function getEnvConfig() {
	return {
		isHome: process.env.IS_HOME === "true",
		isOffice: process.env.IS_OFFICE === "true",
		isServer: process.env.IS_SERVER === "true"
	};
}
function determineEnvironment(sysInfo, config, ip) {
	if (config.isHome) return "home-macos";
	if (config.isOffice) return "office-macos";
	if (config.isServer || ip === KNOWN_IPS.APNAES) return "apnaes";
	if (sysInfo.osName === "Android") return "android";
	return "home-macos";
}
function shellExport(key, value) {
	if (value === void 0) return "";
	return `export ${key}="${value.replace(/"/g, "\\\"").replace(/\$/g, "\\$")}"`;
}
function main() {
	const sysInfo = detectOS();
	const config = getEnvConfig();
	const ip = process.env.IP;
	const zenv = determineEnvironment(sysInfo, config, ip);
	const exports = [
		shellExport("OS_NAME", sysInfo.osName),
		shellExport("OS_VERSION", sysInfo.osVersion),
		shellExport("OS_BUILD", sysInfo.osBuild),
		shellExport("OS_KERNEL", sysInfo.osKernel),
		shellExport("OS_ARCH", sysInfo.arch),
		shellExport("HOSTNAME", sysInfo.hostname),
		shellExport("ZENV", zenv),
		shellExport("ARCHFLAGS", sysInfo.arch === "arm64" ? "-arch arm64" : "-arch x86_64")
	].filter(Boolean);
	console.log(exports.join("\n"));
}
main();

//#endregion
export {  };
//# sourceMappingURL=detect-env.mjs.map