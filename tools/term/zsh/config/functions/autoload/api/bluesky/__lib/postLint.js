import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { firostError, read } from 'firost';
import { parsePostMarkdown } from './parsePostMarkdown.js';
import { validatePost } from './validatePost.js';

export let __;

/**
 * Lint a Draft, without any network call
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @returns {Promise<object[]>} Violations in the unified lint shape. Throws BLUESKY_MISSING_ARGUMENT when there is no text
 */
export async function postLint(options) {
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
  const violations = __.validatePost(__.parsePostMarkdown(markdown));

  return _.map(violations, ({ code, level, line, message }) => ({
    file,
    code,
    level,
    line,
    endLine: line,
    column: 1,
    endColumn: 1,
    message,
  }));
}

__ = {
  read,
  parsePostMarkdown,
  validatePost,
};
