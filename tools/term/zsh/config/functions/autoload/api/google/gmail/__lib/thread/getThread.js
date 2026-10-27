import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Fetch one Thread from the Gmail API
 * @param {string} threadId - Id of the Thread
 * @param {object} [options] - Request options of callApi
 * @returns {Promise<object>} The Thread, as returned by the Gmail API
 */
export async function getThread(threadId, options) {
  try {
    return await __.callApi(`threads/${threadId}`, options);
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
