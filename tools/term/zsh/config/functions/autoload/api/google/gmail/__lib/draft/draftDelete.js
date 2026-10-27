import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Delete one Draft, for good. The Draft does not go to the trash
 * @param {object} options - Delete options
 * @param {string} options.draftId - Id of the Draft, as printed by gmail-draft-create and thread-read. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @returns {Promise<object>} The id of the deleted Draft, as { draftId }. Throws GMAIL_DRAFT_NOT_FOUND if the Draft does not exist
 */
export async function draftDelete(options) {
  const { draftId } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }

  try {
    await __.callApi(`drafts/${draftId}`, { method: 'DELETE' });
  } catch (error) {
    // callApi starts the message of a failed request with the HTTP status
    const isNotFound =
      error.code === 'GMAIL_REQUEST_FAILED' && error.message.startsWith('404');
    if (!isNotFound) {
      throw error;
    }
    throw firostError('GMAIL_DRAFT_NOT_FOUND', `Draft ${draftId} not found`);
  }

  return { draftId };
}

__ = {
  callApi,
};
