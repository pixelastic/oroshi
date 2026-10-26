import { callApi as googleCallApi } from '@oroshi/google/callApi.js';

const BASE_URL = 'https://gmail.googleapis.com/gmail/v1/users/me';

/**
 * Call the Gmail API, for the current user
 * @param {string} path - Path of the endpoint
 * @param {object} [options] - Request options of the shared callApi
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  return await googleCallApi(path, {
    baseUrl: BASE_URL,
    ...options,
    errorCode: 'GMAIL_REQUEST_FAILED',
  });
}
