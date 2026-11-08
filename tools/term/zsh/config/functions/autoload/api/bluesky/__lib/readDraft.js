import { resolve } from 'node:path';
import { firostError, read } from 'firost';

export let __;

/**
 * Read the Markdown of a Draft given with --text or --text-file
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @returns {Promise<{file: string, markdown: string}>} The Markdown, and the file it comes from (`<text>` for inline text). Throws BLUESKY_MISSING_ARGUMENT when there is no text
 */
export async function readDraft(options) {
  const { text, textFile } = options;

  if (!text && !textFile) {
    throw firostError(
      'BLUESKY_MISSING_ARGUMENT',
      'Pass the --text or --text-file',
    );
  }

  // firost resolves a relative path from its own folder, not from the caller
  const file = textFile ? resolve(textFile) : '<text>';
  const markdown = textFile ? await __.read(file) : text;

  return { file, markdown };
}

__ = {
  read,
};
