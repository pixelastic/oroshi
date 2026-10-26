import { _ } from 'golgoth';
import { convert } from 'html-to-text';
import { extractAttachments } from '../extractAttachments.js';
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
    const plain = __.findPart(payload, 'text/plain');
    if (plain) {
      return __.decode(plain.body.data);
    }
    const html = __.findPart(payload, 'text/html');
    if (html) {
      return convert(__.decode(html.body.data), {
        wordwrap: false,
        selectors: [{ selector: 'img', format: 'skip' }],
      });
    }
    return '';
  },

  /**
   * Find the first part with the given mime type, walking nested multiparts
   * @param {object} part - Gmail mail part
   * @param {string} mimeType - Mime type to find
   * @returns {object|undefined} The part, if it has inline data
   */
  findPart(part, mimeType) {
    if (!part) {
      return undefined;
    }
    if (part.mimeType === mimeType && part.body?.data) {
      return part;
    }
    return _.chain(part.parts)
      .map((child) => __.findPart(child, mimeType))
      .find()
      .value();
  },

  /**
   * Decode base64url content as UTF-8
   * @param {string} data - base64url string
   * @returns {string} Decoded text
   */
  decode(data) {
    return Buffer.from(data, 'base64url').toString('utf8');
  },
};
