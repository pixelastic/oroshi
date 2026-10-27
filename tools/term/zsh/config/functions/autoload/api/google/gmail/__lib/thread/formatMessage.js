import { _ } from 'golgoth';
import { convert } from 'html-to-text';
import { extractAttachments } from '../extractAttachments.js';
import { extractBodies } from '../extractBodies.js';
import { header } from '../header.js';

export let __;

/**
 * Format one Message, with its decoded body
 * @param {object} message - Gmail message resource
 * @param {object} [options] - Format options
 * @param {string} [options.format] - Format the Message was fetched with: full (default) or metadata
 * @returns {object} The Message as { messageId, from, to, subject, date, snippet, body, attachments }. The metadata format provides no recipient, body or attachment, so those keys are absent
 */
export function formatMessage(message, options = {}) {
  const { format = 'full' } = options;
  const metadata = {
    messageId: message.id,
    from: header(message, 'From'),
    subject: header(message, 'Subject'),
    date: header(message, 'Date'),
    snippet: message.snippet || '',
  };
  if (format === 'metadata') {
    return metadata;
  }

  return {
    ...metadata,
    to: header(message, 'To'),
    body: __.extractBody(message.payload),
    attachments: _.map(extractAttachments(message.payload), (attachment) =>
      _.omit(attachment, 'attachmentId'),
    ),
  };
}

__ = {
  /**
   * Extract the readable body of a Message payload. Prefers text/plain and
   * falls back to HTML converted to text
   * @param {object} payload - Gmail message payload
   * @returns {string} Body text, or an empty string if there is none
   */
  extractBody(payload) {
    const { text, html } = extractBodies(payload);
    if (text) {
      return text;
    }
    if (html) {
      return convert(html, {
        wordwrap: false,
        selectors: [{ selector: 'img', format: 'skip' }],
      });
    }
    return '';
  },
};
