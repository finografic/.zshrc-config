#!/usr/bin/env tsx
// ============================================================================
// DETECT-ENV - Environment detection for zshrc-config
// ============================================================================
// Outputs shell exports that can be eval'd:
//   eval "$(tsx node/src/detect-env.ts)"
// ============================================================================

import { execSync } from 'child_process';
import type { OSName, ZEnv, SystemInfo, EnvConfig } from './types.js';
import { KNOWN_IPS } from './types.js';

// ============================================================================
// OS DETECTION
// ============================================================================

function detectOS(): SystemInfo {
  const platform = process.platform;
  const arch = process.arch === 'arm64' ? 'arm64' : 'x86_64';
  const hostname = execSync('hostname', { encoding: 'utf-8' }).trim();

  if (platform === 'darwin') {
    // macOS
    const osVersion = execSync('sw_vers -productVersion', { encoding: 'utf-8' }).trim();
    const osBuild = execSync('sw_vers -buildVersion', { encoding: 'utf-8' }).trim();
    return {
      osName: 'macOS',
      osVersion,
      osBuild,
      arch,
      hostname,
    };
  } else if (platform === 'linux') {
    // Linux or Android
    const osVersion = execSync('uname -v', { encoding: 'utf-8' }).trim();
    const osKernel = execSync('uname -r', { encoding: 'utf-8' }).trim();

    // Check for Android
    const isAndroid = process.env.ANDROID_ROOT !== undefined ||
      process.env.TERMUX_VERSION !== undefined;

    return {
      osName: isAndroid ? 'Android' : 'Linux',
      osVersion,
      osKernel,
      arch,
      hostname,
    };
  } else if (platform === 'win32') {
    return {
      osName: 'Windows',
      osVersion: process.version,
      arch,
      hostname,
    };
  }

  return {
    osName: 'Unknown',
    osVersion: 'unknown',
    arch,
    hostname,
  };
}

// ============================================================================
// ENVIRONMENT DETECTION
// ============================================================================

function getEnvConfig(): EnvConfig {
  return {
    isHome: process.env.IS_HOME === 'true',
    isOffice: process.env.IS_OFFICE === 'true',
    isServer: process.env.IS_SERVER === 'true',
  };
}

function determineEnvironment(sysInfo: SystemInfo, config: EnvConfig, ip?: string): ZEnv {
  // Check explicit environment flags first
  if (config.isHome) {
    return 'home-macos';
  }

  if (config.isOffice) {
    return 'office-macos';
  }

  if (config.isServer || ip === KNOWN_IPS.APNAES) {
    return 'apnaes';
  }

  if (sysInfo.osName === 'Android') {
    return 'android';
  }

  // Default
  return 'home-macos';
}

// ============================================================================
// OUTPUT SHELL EXPORTS
// ============================================================================

function shellExport(key: string, value: string | undefined): string {
  if (value === undefined) return '';
  // Escape special characters for shell
  const escaped = value.replace(/"/g, '\\"').replace(/\$/g, '\\$');
  return `export ${key}="${escaped}"`;
}

function main(): void {
  const sysInfo = detectOS();
  const config = getEnvConfig();
  const ip = process.env.IP; // IP is set by shell before calling this
  const zenv = determineEnvironment(sysInfo, config, ip);

  const exports: string[] = [
    shellExport('OS_NAME', sysInfo.osName),
    shellExport('OS_VERSION', sysInfo.osVersion),
    shellExport('OS_BUILD', sysInfo.osBuild),
    shellExport('OS_KERNEL', sysInfo.osKernel),
    shellExport('OS_ARCH', sysInfo.arch),
    shellExport('HOSTNAME', sysInfo.hostname),
    shellExport('ZENV', zenv),
    shellExport('ARCHFLAGS', sysInfo.arch === 'arm64' ? '-arch arm64' : '-arch x86_64'),
  ].filter(Boolean);

  console.log(exports.join('\n'));
}

main();
