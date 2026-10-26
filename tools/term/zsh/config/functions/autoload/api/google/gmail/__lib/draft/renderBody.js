import path from 'node:path';
import { firostError } from 'firost';
import { marked } from 'marked';

/**
 * Render the body of a draft from --body or --body-file
 * @param {object} options - Body options
 * @param {string} [options.body] - Body given with --body, kept as is
 * @param {object} [options.file] - Body given with --body-file, as { path, content }
 * @returns {{ text: string, html?: string }} The text part, and the HTML part for a .md file. Throws GMAIL_BODY_CONFLICT when both are given, GMAIL_BODY_MISSING when none is
 */
export function renderBody(options) {
  const { body, file } = options;

  if (body && file) {
    throw firostError(
      'GMAIL_BODY_CONFLICT',
      'Pass either --body or --body-file, not both',
    );
  }
  if (!body && !file) {
    throw firostError('GMAIL_BODY_MISSING', 'Pass the --body or --body-file');
  }

  if (!file) {
    return { text: body };
  }
  if (path.extname(file.path).toLowerCase() !== '.md') {
    return { text: file.content };
  }
  return { text: file.content, html: marked.parse(file.content).trim() };
}
