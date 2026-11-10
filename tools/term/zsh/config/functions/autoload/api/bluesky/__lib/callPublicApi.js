import { firostError } from 'firost';
import { queryString } from '@oroshi/api-shared/queryString.js';

export let __;

const PUBLIC_API = 'https://public.api.bsky.app';

/**
 * Call the public AppView, without any session. It reads public data of any account and needs no scope
 * @param {string} path - NSID of the XRPC method
 * @param {object} [options] - Request options
 * @param {object} [options.query] - Query parameters
 * @returns {Promise<object>} The parsed response of the API
 */
export async function callPublicApi(path, options = {}) {
  const { query } = options;

  let response;
  let text;
  try {
    response = await __.fetch(
      `${PUBLIC_API}/xrpc/${path}${queryString(query)}`,
    );
    text = await response.text();
  } catch (error) {
    throw firostError('BLUESKY_REQUEST_FAILED', error.message);
  }

  if (!response.ok) {
    throw firostError('BLUESKY_REQUEST_FAILED', `${response.status} ${text}`);
  }

  try {
    return JSON.parse(text);
  } catch {
    throw firostError('BLUESKY_REQUEST_FAILED', text);
  }
}

__ = {
  fetch,
};
