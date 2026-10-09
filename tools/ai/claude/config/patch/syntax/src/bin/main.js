import { parseArgs } from 'node:util';
import { main } from '../main.js';

const { values } = parseArgs({
  options: {
    binary: { type: 'string' },
    colors: { type: 'string' },
  },
});
await main({
  binaryPath: values.binary,
  colorsPath: values.colors,
});
