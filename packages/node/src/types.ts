// ============================================================================
// TYPES - Shared types for zshrc-config node utilities
// ============================================================================

export type ZEnv =
  | 'home-macos'
  | 'office-macos'
  | 'apnaes'
  | 'android'
  | 'docker-container'
  | 'vscode';

export type OSName = 'macOS' | 'Linux' | 'Android' | 'Windows' | 'Unknown';

export interface SystemInfo {
  osName: OSName;
  osVersion: string;
  osBuild?: string;
  osKernel?: string;
  arch: 'arm64' | 'x86_64' | string;
  hostname: string;
}

export interface EnvConfig {
  isHome: boolean;
  isOffice: boolean;
  isServer: boolean;
}

// Known IP addresses for environment detection
export const KNOWN_IPS = {
  APNAES: 'REDACTED-IP',
  OFFICE: 'REDACTED-IP',
  HOME: 'REDACTED-IP',
} as const;
