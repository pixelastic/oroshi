import { stat } from 'node:fs/promises';
import { exists } from 'firost';

/**
 * Get the size of a file
 * @param {string} filepath - Absolute path of the file
 * @returns {Promise<number|null>} Size in bytes, or null when the file does not exist
 */
export async function fileSize(filepath) {
  if (!(await exists(filepath))) {
    return null;
  }
  const { size } = await stat(filepath);
  return size;
}
