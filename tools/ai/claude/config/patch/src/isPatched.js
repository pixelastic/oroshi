import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { patches } from './patches.js';

/**
 * Check if the Claude Code binary already carries a registered patch
 * @param {string} binaryPath - Path to the claude.exe binary
 * @param {string} name - Name of the patch
 * @returns {Promise<boolean>} True when the patch is present
 */
export async function isPatched(binaryPath, name) {
  const binary = await readFile(binaryPath);
  return patches[name].isPatched(binary.toString('latin1'));
}

// Usage: node isPatched.js --binary <path> --name <patch>
// Exits 0 when the patch is present, 1 otherwise
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const { values } = parseArgs({
    options: {
      binary: { type: 'string' },
      name: { type: 'string' },
    },
  });
  const result = await isPatched(values.binary, values.name);
  process.exitCode = result ? 0 : 1;
}
