import { _ } from 'golgoth';

/**
 * List the attachments of a mail payload, walking nested multiparts
 * @param {object} part - Gmail mail part
 * @returns {object[]} Array of { partId, attachmentId, filename, mimeType, size }
 */
export function extractAttachments(part) {
  if (!part) {
    return [];
  }
  const children = _.flatMap(part.parts, extractAttachments);
  if (!part.filename || !part.body?.attachmentId) {
    return children;
  }
  return [
    {
      partId: part.partId,
      attachmentId: part.body.attachmentId,
      filename: part.filename,
      mimeType: part.mimeType,
      size: part.body.size,
    },
    ...children,
  ];
}
