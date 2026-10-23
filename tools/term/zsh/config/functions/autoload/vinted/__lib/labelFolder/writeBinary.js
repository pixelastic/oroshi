import { writeFile } from 'node:fs/promises';
import path from 'node:path';
import { mkdirp } from 'firost';

/**
 * Write bytes to a file, creating its folder
 * firost write only handles text, so a PDF goes through here.
 * @param {Uint8Array} bytes - Content to write
 * @param {string} filepath - Path of the file
 */
export async function writeBinary(bytes, filepath) {
  await mkdirp(path.dirname(filepath));
  await writeFile(filepath, bytes);
}
