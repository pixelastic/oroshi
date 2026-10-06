// firost read/write only handle text (read decodes utf8 and trims, write
// ignores Buffers), so the binary is read and written with node:fs
import { chmod, readFile, stat, writeFile } from 'node:fs/promises';
import { _ } from 'golgoth';
import { move } from 'firost';
import { stripModuleBytecode } from './stripModuleBytecode.js';

/**
 * Rewrite the Claude Code binary with a patched version of its content.
 * The binary is left untouched when nothing is patched.
 * @param {string} binaryPath - Path to the claude.exe binary
 * @param {Function} patchText - Receives the binary as a latin1 string, returns { text, offsets } with the exact input length
 * @returns {Promise<boolean>} True when the binary was rewritten
 */
export async function patchBinary(binaryPath, patchText) {
  const binary = await readFile(binaryPath);
  const { text, offsets } = patchText(binary.toString('latin1'));
  if (_.isEmpty(offsets)) {
    return false;
  }

  const patchedBinary = Buffer.from(text, 'latin1');
  // Bun runs the precompiled bytecode over the source, so it must be removed
  stripModuleBytecode(patchedBinary, offsets);

  // Write to a new file then rename: the binary can't be written while
  // running (ETXTBSY), and yarn hardlinks it to its global cache
  const temporaryPath = `${binaryPath}.patch`;
  const { mode } = await stat(binaryPath);
  await writeFile(temporaryPath, patchedBinary);
  await chmod(temporaryPath, mode);
  await move(temporaryPath, binaryPath);
  return true;
}
