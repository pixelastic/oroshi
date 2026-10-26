import { firostError } from 'firost';
import { getClientCredentials } from './getClientCredentials.js';

export let __;

const TOKEN_URL = 'https://oauth2.googleapis.com/token';

/**
 * Post a grant to the Google token endpoint, and get tokens back
 * @param {object} params - Form fields of the grant (grant_type, code, refresh_token, redirect_uri...). The client id and secret are added
 * @returns {Promise<object>} The JSON response of the token endpoint
 */
export async function postToken(params) {
  const { clientId, clientSecret } = __.getClientCredentials();

  const body = new URLSearchParams({
    ...params,
    client_id: clientId,
    client_secret: clientSecret,
  }).toString();

  const response = await __.fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });

  const text = await response.text();

  // The body of Google holds the reason of the failure
  if (!response.ok) {
    throw firostError('GOOGLE_REQUEST_FAILED', text);
  }

  return JSON.parse(text);
}

__ = {
  fetch,
  getClientCredentials,
};
