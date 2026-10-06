import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { applyPatches } from '../../src/applyPatches.js';

/**
 * Patch the Claude Code binary so Down, instead of Right, accepts the
 * prompt suggestion.
 * @param {object} options - Options
 * @param {string} options.binaryPath - Path to the claude.exe binary
 */
export async function main({ binaryPath }) {
  await applyPatches(binaryPath, ['suggestion']);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const { values } = parseArgs({
    options: {
      binary: { type: 'string' },
    },
  });
  await main({ binaryPath: values.binary });
}
