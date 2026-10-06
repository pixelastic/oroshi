import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { read, readJson } from 'firost';
import { parse as parseJsonc } from 'jsonc-parser';
import { patchBinary } from '../../src/patchBinary.js';
import { resolveColors } from './resolveColors.js';
import { syntaxPatch } from './syntaxPatch.js';

/**
 * Patch the Claude Code binary so its syntax highlighting uses our colors
 * instead of the hardcoded Monokai Extended ones.
 * @param {object} options - Options
 * @param {string} options.binaryPath - Path to the claude.exe binary
 * @param {string} options.colorsPath - Path to colors.json
 */
export async function main({ binaryPath, colorsPath }) {
  const colors = await readJson(colorsPath);
  const config = parseJsonc(await read('./claude-syntax.jsonc'));
  const scopeColors = resolveColors(config.scopes, colors);
  const decorationColors = resolveColors(config.diff, colors);

  // Patched even when already patched, to apply changed colors
  await patchBinary(binaryPath, (text) =>
    syntaxPatch.patch(text, { scopeColors, decorationColors }),
  );
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
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
}
