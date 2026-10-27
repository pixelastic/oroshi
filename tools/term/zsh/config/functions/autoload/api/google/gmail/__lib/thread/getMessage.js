import { firostError } from 'firost';
import { callApi } from '../callApi.js';

export let __;

/**
 * Fetch one Message from the Gmail API
 * @param {string} messageId - Id of the Message
 * @param {object} [options] - Request options of callApi
 * @returns {Promise<object>} The Message, as returned by the Gmail API
 */
export async function getMessage(messageId, options) {
  try {
    return await __.callApi(`messages/${messageId}`, options);
  } catch (error) {
    const { code, message } = error;
    // callApi starts the message of a failed request with the HTTP status
    if (code === 'GMAIL_REQUEST_FAILED' && message.startsWith('404')) {
      throw firostError(
        'GMAIL_MESSAGE_NOT_FOUND',
        `Message ${messageId} not found`,
      );
    }

    throw error;
  }
}

__ = {
  callApi,
};
