import { defineConfig } from 'tsdown';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm'],
  platform: 'node',
  target: 'node22',
  clean: true,
  dts: false,
  // The bin entry is executed directly by the `zconf` zsh wrapper.
  outputOptions: {
    banner: '#!/usr/bin/env node',
  },
});
