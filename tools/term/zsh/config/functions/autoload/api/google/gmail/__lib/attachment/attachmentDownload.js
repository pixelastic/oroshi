import { writeFile } from 'node:fs/promises';
import path from 'node:path';
import { _ } from 'golgoth';
import { firostError, isDirectory, mkdirp } from 'firost';
import { callApi } from '../callApi.js';
import { extractAttachments } from '../extractAttachments.js';
import { getMessage } from '../thread/getMessage.js';

export let __;

/**
 * Download one attachment of a Message
 * @param {object} options - Download options
 * @param {string} options.messageId - Id of the Message, as printed by thread-read. Throws GMAIL_MESSAGE_ID_MISSING if empty
 * @param {string} options.partId - Part id, as listed in the attachments of thread-read. Throws GMAIL_PART_ID_MISSING if empty
 * @param {string} [options.out] - Existing directory (keeps the remote filename)
 * or file path. Defaults to the current directory
 * @returns {Promise<string>} Path of the saved file
 */
export async function attachmentDownload(options) {
  const { messageId, partId, out } = options;

  if (!messageId) {
    throw firostError('GMAIL_MESSAGE_ID_MISSING', 'Pass the id of a Message');
  }
  if (!partId) {
    throw firostError('GMAIL_PART_ID_MISSING', 'Pass the --partId of the part');
  }

  const message = await __.getMessage(messageId, {
    query: { format: 'full' },
  });
  const attachment = _.find(
    __.extractAttachments(message.payload),
    (item) => item.partId === partId,
  );
  if (!attachment) {
    throw firostError(
      'GMAIL_ATTACHMENT_NOT_FOUND',
      `Attachment not found in Message ${messageId}: part ${partId}`,
    );
  }

  const { data } = await __.callApi(
    `messages/${messageId}/attachments/${attachment.attachmentId}`,
  );
  const filepath = await __.resolveOutput(out, attachment.filename);
  await mkdirp(path.dirname(filepath));
  await writeFile(filepath, Buffer.from(data, 'base64url'));
  return filepath;
}

__ = {
  /**
   * Choose where to save the file. An existing directory receives the file
   * under its remote name. Any other value is used as the file path
   * @param {string} [out] - Value of --out
   * @param {string} filename - Remote filename
   * @returns {Promise<string>} Absolute file path
   */
  async resolveOutput(out, filename) {
    // No --out: save in the current directory
    if (!out) {
      return path.resolve(path.basename(filename));
    }
    if (await isDirectory(path.resolve(out))) {
      return path.resolve(out, path.basename(filename));
    }
    return path.resolve(out);
  },

  callApi,
  extractAttachments,
  getMessage,
};
