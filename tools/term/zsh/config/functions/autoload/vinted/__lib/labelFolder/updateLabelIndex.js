import path from 'node:path';
import { writeJson } from 'firost';
import { LABEL_INDEX_FILE, readLabelIndex } from './readLabelIndex.js';

/**
 * Add entries to the index of a label folder
 * An entry with an existing label file name replaces the old one.
 * @param {string} labelsDirectory - Folder holding the label PDFs
 * @param {object} entries - Entries by label file name
 * @returns {Promise<object>} The index after the update
 */
export async function updateLabelIndex(labelsDirectory, entries) {
  const index = { ...(await readLabelIndex(labelsDirectory)), ...entries };
  await writeJson(index, path.join(labelsDirectory, LABEL_INDEX_FILE));
  return index;
}
