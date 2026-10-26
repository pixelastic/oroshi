import { callApi as googleCallApi } from '@oroshi/google/callApi.js';

const BASE_URL = 'https://docs.googleapis.com/v1';

/**
 * Call the Google Docs API, or the Drive API with a baseUrl
 * @param {string} path - Path of the endpoint
 * @param {object} [options] - Request options of the shared callApi
 * @param {string} [options.baseUrl] - Base URL of the endpoint, https://www.googleapis.com/drive/v3 for Drive
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  return await googleCallApi(path, {
    baseUrl: BASE_URL,
    ...options,
    errorCode: 'GDOC_REQUEST_FAILED',
  });
}
