import path from 'node:path';
import { exists, readJson } from 'firost';

export const LABEL_INDEX_FILE = 'index.json';

/**
 * Read the index of a label folder
 * It maps each label file to the conversation and the item ids it covers.
 * @param {string} labelsDirectory - Folder holding the label PDFs
 * @returns {Promise<object>} Entries by label file name, empty when no index
 */
export async function readLabelIndex(labelsDirectory) {
  const filepath = path.join(labelsDirectory, LABEL_INDEX_FILE);
  if (!(await exists(filepath))) {
    return {};
  }
  return await readJson(filepath);
}
