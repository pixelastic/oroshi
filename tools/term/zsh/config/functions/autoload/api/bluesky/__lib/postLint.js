import { _ } from 'golgoth';
import { parsePostMarkdown } from './parsePostMarkdown.js';
import { readDraft } from './readDraft.js';
import { validatePost } from './validatePost.js';

export let __;

/**
 * Lint a Draft, without any network call
 * @param {object} options - Options of the command
 * @param {string} [options.text] - Markdown given with --text
 * @param {string} [options.textFile] - Path of the Markdown file given with --text-file, which wins over the text
 * @param {boolean} [options.thread] - Lint each post of a Thread, split on the lines of three dashes
 * @returns {Promise<object[]>} Violations in the unified lint shape. Throws BLUESKY_MISSING_ARGUMENT when there is no text
 */
export async function postLint(options) {
  const { file, directory, markdown } = await __.readDraft(options);
  const posts = __.parsePostMarkdown(markdown, {
    directory,
    thread: options.thread,
  });
  const violations = await __.validatePost(posts);

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
  readDraft,
  parsePostMarkdown,
  validatePost,
};
