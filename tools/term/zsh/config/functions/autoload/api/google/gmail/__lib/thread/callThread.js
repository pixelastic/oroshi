import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Post an action on a Thread
 * @param {object} options - Call options
 * @param {string} options.threadId - Id of the Thread
 * @param {string} options.action - Action of the endpoint: modify, trash or untrash
 * @param {object} [options.body] - Body of the request
 * @returns {Promise<object>} The Thread, as returned by the Gmail API. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function callThread(options) {
  const { threadId, action, body } = options;

  try {
    return await __.callApi(`threads/${threadId}/${action}`, {
      method: 'POST',
      ...(body && { body }),
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
