import crypto from 'node:crypto';
import { callApi } from '../callApi.js';

export let __;

const UPLOAD_BASE_URL = 'https://gmail.googleapis.com/upload/gmail/v1/users/me';

/**
 * Replace the content of a Draft, through the upload endpoint
 * @param {object} options - Save options
 * @param {string} options.draftId - Id of the Draft to replace
 * @param {string} options.threadId - Id of the Thread of the Draft
 * @param {Buffer} options.mime - The new MIME of the Draft
 * @returns {Promise<object>} The saved Draft, as returned by the Gmail API
 */
export async function saveDraft(options) {
  const { draftId, threadId, mime } = options;

  const boundary = `oroshi-${crypto.randomUUID()}`;
  const body = Buffer.concat([
    Buffer.from(
      [
        `--${boundary}`,
        'Content-Type: application/json; charset=UTF-8',
        '',
        JSON.stringify({ message: { threadId } }),
        `--${boundary}`,
        'Content-Type: message/rfc822',
        '',
        '',
      ].join('\r\n'),
    ),
    mime,
    Buffer.from(`\r\n--${boundary}--`),
  ]);

  return await __.callApi(`drafts/${draftId}`, {
    method: 'PUT',
    baseUrl: UPLOAD_BASE_URL,
    query: { uploadType: 'multipart' },
    headers: { 'Content-Type': `multipart/related; boundary=${boundary}` },
    body,
  });
}

__ = {
  callApi,
};
