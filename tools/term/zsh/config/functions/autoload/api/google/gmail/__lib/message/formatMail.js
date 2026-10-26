import { _ } from 'golgoth';
import { convert } from 'html-to-text';
import { extractAttachments } from '../extractAttachments.js';
import { extractBodies } from '../extractBodies.js';
import { header } from '../header.js';

export let __;

/**
 * Format one Mail of a Message, with its decoded body
 * @param {object} mail - Gmail message resource, fetched with the full format
 * @returns {object} The Mail as { id, from, to, subject, date, snippet, body, attachments }
 */
export function formatMail(mail) {
  return {
    id: mail.id,
    from: header(mail, 'From'),
    to: header(mail, 'To'),
    subject: header(mail, 'Subject'),
    date: header(mail, 'Date'),
    snippet: mail.snippet || '',
    body: __.extractBody(mail.payload),
    attachments: _.map(extractAttachments(mail.payload), (attachment) =>
      _.omit(attachment, 'attachmentId'),
    ),
  };
}

__ = {
  /**
   * Extract the readable body of a mail payload. Prefers text/plain and
   * falls back to HTML converted to text
   * @param {object} payload - Gmail mail payload
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
