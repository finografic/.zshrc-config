import { defineConfig } from 'tsdown';

export default defineConfig({
  entry: {
    'detect-env': 'src/detect-env.ts',
    'build-path': 'src/build-path.ts',
    'spinner': 'src/spinner.ts',
  },
  format: ['esm'],
  dts: true,
  clean: true,
  sourcemap: true,
  target: 'esnext',
});
