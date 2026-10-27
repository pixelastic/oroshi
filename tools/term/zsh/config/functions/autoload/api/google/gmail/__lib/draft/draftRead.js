import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatMessage } from '../thread/formatMessage.js';

export let __;

/**
 * Read one Draft, with its attachments
 * @param {object} options - Read options
 * @param {string} options.draftId - Id of the Draft, as printed by gmail-draft-create and thread-read. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @returns {Promise<object>} The Draft as { draftId, threadId, messageId, from, to, subject, body, attachments }. Throws GMAIL_DRAFT_NOT_FOUND if the Draft does not exist
 */
export async function draftRead(options) {
  const { draftId } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }

  const draft = await __.getDraft(draftId);
  const message = formatMessage(draft.message);

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    ..._.omit(message, ['date', 'snippet']),
  };
}

__ = {
  /**
   * Fetch one Draft from the Gmail API, in full format
   * @param {string} draftId - Id of the Draft
   * @returns {Promise<object>} The Draft, as returned by the Gmail API
   */
  async getDraft(draftId) {
    try {
      return await __.callApi(`drafts/${draftId}`, {
        query: { format: 'full' },
      });
    } catch (error) {
      // callApi starts the message of a failed request with the HTTP status
      const isNotFound =
        error.code === 'GMAIL_REQUEST_FAILED' &&
        error.message.startsWith('404');
      if (!isNotFound) {
        throw error;
      }
      throw firostError('GMAIL_DRAFT_NOT_FOUND', `Draft ${draftId} not found`);
    }
  },

  callApi,
};
