import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Fetch one Draft from the Gmail API
 * @param {string} draftId - Id of the Draft
 * @param {string} format - Format of the Draft: full or raw
 * @returns {Promise<object>} The Draft, as returned by the Gmail API. Throws GMAIL_DRAFT_NOT_FOUND if the Draft does not exist
 */
export async function getDraft(draftId, format) {
  try {
    return await __.callApi(`drafts/${draftId}`, { query: { format } });
  } catch (error) {
    // callApi starts the message of a failed request with the HTTP status
    const isNotFound =
      error.code === 'GMAIL_REQUEST_FAILED' && error.message.startsWith('404');
    if (!isNotFound) {
      throw error;
    }
    throw firostError('GMAIL_DRAFT_NOT_FOUND', `Draft ${draftId} not found`);
  }
}

__ = {
  callApi,
};
