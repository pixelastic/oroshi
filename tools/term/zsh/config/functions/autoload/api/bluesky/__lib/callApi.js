import { _ } from 'golgoth';
import { firostError } from 'firost';
import { queryString } from '@oroshi/api-shared/queryString.js';
import { createOAuthClient } from './createOAuthClient.js';
import { createStores } from './createStores.js';
import { __ as configInternals, getConfig } from './getConfig.js';
import { loginCommand } from './loginCommand.js';
import { tokensPath } from './tokensPath.js';

export let __;

/**
 * Call the PDS of the logged-in account with the saved OAuth session
 * @param {string} path - NSID of the XRPC method
 * @param {object} [options] - Request options
 * @param {string} [options.method] - HTTP method
 * @param {object|Buffer|string} [options.body] - Body of the request. A plain object is sent as JSON, anything else untouched
 * @param {object} [options.query] - Query parameters
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  const { method = 'GET', body, query, headers } = options;

  const loginRequired = firostError(
    'BLUESKY_LOGIN_REQUIRED',
    loginCommand(configInternals.account),
  );

  // The tokens file holds the sessions of the DIDs that logged in
  const { tokens } = await __.getConfig();
  const [did] = _.keys(tokens.sessions);
  if (!did) {
    throw loginRequired;
  }

  // The library refreshes the tokens when restoring, and fails when it can't
  let session;
  try {
    const client = __.createOAuthClient(
      createStores(tokensPath(configInternals.account)),
    );
    session = await client.restore(did);
  } catch {
    throw loginRequired;
  }

  // A plain object is sent as JSON
  const isJson = _.isPlainObject(body);
  const defaultHeaders = isJson ? { 'Content-Type': 'application/json' } : {};

  // The session signs the request (DPoP), and sends it to the PDS
  let response;
  try {
    response = await session.fetchHandler(
      `/xrpc/${path}${queryString(query)}`,
      {
        method,
        headers: { ...defaultHeaders, ...headers },
        body: isJson ? JSON.stringify(body) : body,
      },
    );
  } catch (error) {
    throw firostError('BLUESKY_REQUEST_FAILED', error.message);
  }

  // Read the body as text, so that an empty body does not throw
  const text = await response.text();

  // The library already refreshed the tokens, so a 401 is final
  if (response.status === 401) {
    throw loginRequired;
  }
  if (!response.ok) {
    throw firostError('BLUESKY_REQUEST_FAILED', `${response.status} ${text}`);
  }

  // Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError('BLUESKY_REQUEST_FAILED', text);
  }
}

__ = {
  createOAuthClient,
  getConfig,
};
