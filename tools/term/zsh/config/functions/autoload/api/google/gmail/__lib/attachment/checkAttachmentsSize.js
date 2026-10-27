import { _ } from 'golgoth';
import { firostError } from 'firost';

// Gmail refuses a message above 25 MB, counted once the attachments are in base64
const MAX_BYTES = 25 * 1024 * 1024;

/**
 * Check that the attachments fit in a Gmail message
 * @param {object[]} attachments - Attachments, as { content }. content is a Buffer
 * @returns {void} Throws GMAIL_ATTACHMENTS_TOO_LARGE if they are above 25 MB in base64
 */
export function checkAttachmentsSize(attachments) {
  const rawBytes = _.sumBy(attachments, (attachment) => {
    return attachment.content.length;
  });
  // Base64 turns 3 bytes into 4 characters
  const base64Bytes = Math.ceil(rawBytes / 3) * 4;

  if (base64Bytes > MAX_BYTES) {
    const megabytes = (base64Bytes / 1024 / 1024).toFixed(1);
    throw firostError(
      'GMAIL_ATTACHMENTS_TOO_LARGE',
      `The attachments weigh ${megabytes} MB in base64, above the 25 MB limit`,
    );
  }
}
