import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Add and remove labels on every Message of a Thread
 * @param {object} options - Modification options
 * @param {string} options.threadId - Id of the Thread
 * @param {string[]} [options.add] - Ids of the labels to add
 * @param {string[]} [options.remove] - Ids of the labels to remove
 * @returns {Promise<object>} The Thread, as returned by the Gmail API. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function modifyLabels(options) {
  const { threadId, add, remove } = options;

  try {
    return await __.callApi(`threads/${threadId}/modify`, {
      method: 'POST',
      body: { addLabelIds: add, removeLabelIds: remove },
    });
  } catch (error) {
    // callApi starts the message of a failed request with the HTTP status
    const isNotFound =
      error.code === 'GMAIL_REQUEST_FAILED' && error.message.startsWith('404');
    if (!isNotFound) {
      throw error;
    }
    throw firostError('GMAIL_THREAD_NOT_FOUND', `Thread ${threadId} not found`);
  }
}

__ = {
  callApi,
};
