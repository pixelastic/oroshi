import { _ } from 'golgoth';

export let __;

/**
 * Extract the decoded text and HTML bodies of a Message payload
 * @param {object} payload - Gmail Message payload
 * @returns {object} { text, html }, each an empty string if the Message has no such part
 */
export function extractBodies(payload) {
  return {
    text: __.readPart(payload, 'text/plain'),
    html: __.readPart(payload, 'text/html'),
  };
}

__ = {
  /**
   * Read the first part with the given mime type, walking nested multiparts
   * @param {object} part - Gmail Message part
   * @param {string} mimeType - Mime type to read
   * @returns {string} Decoded content, or an empty string if no part has inline data
   */
  readPart(part, mimeType) {
    if (!part) {
      return '';
    }
    if (part.mimeType === mimeType && part.body?.data) {
      return Buffer.from(part.body.data, 'base64url').toString('utf8');
    }
    return _.chain(part.parts)
      .map((child) => __.readPart(child, mimeType))
      .find()
      .defaultTo('')
      .value();
  },
};
