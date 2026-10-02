// firost read/write only handle text (read decodes utf8 and trims, write
// ignores Buffers), so the binary is read and written with node:fs
import { chmod, readFile, stat, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { move, read, readJson } from 'firost';
import { parse as parseJsonc } from 'jsonc-parser';
import { patchHighlightTables } from './patchHighlightTables.js';
import { resolveColors } from './resolveColors.js';

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

  const binary = await readFile(binaryPath);
  const { text } = patchHighlightTables(
    binary.toString('latin1'),
    scopeColors,
    decorationColors,
  );
  const patchedBinary = Buffer.from(text, 'latin1');

  // Write to a new file then rename: the binary can't be written while
  // running (ETXTBSY), and yarn hardlinks it to its global cache
  const temporaryPath = `${binaryPath}.syntax-patch`;
  const { mode } = await stat(binaryPath);
  await writeFile(temporaryPath, patchedBinary);
  await chmod(temporaryPath, mode);
  await move(temporaryPath, binaryPath);
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
