import { _ } from 'golgoth';
import { firostError } from 'firost';
import { queryString } from '@oroshi/api-shared/queryString.js';
import { __ as configInternals, getConfig } from './getConfig.js';
import { loginCommand } from './loginCommand.js';
import { refreshTokens } from './refreshTokens.js';

export let __;

// Tokens that expire within this delay (in ms) are refreshed
const EXPIRY_MARGIN = 60_000;

/**
 * Call a Google API with the OAuth tokens of the selected account
 * @param {string} path - Path of the endpoint
 * @param {object} options - Request options
 * @param {string} options.baseUrl - Base URL of the endpoint
 * @param {string} [options.errorCode] - Code of the error thrown on a failed request
 * @param {string} [options.method] - HTTP method
 * @param {object|FormData|Buffer|string} [options.body] - Body of the request. A plain object is sent as JSON, anything else untouched
 * @param {object} [options.query] - Query parameters
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options) {
  const {
    baseUrl,
    errorCode = 'GOOGLE_REQUEST_FAILED',
    method = 'GET',
    body,
    query,
    headers,
  } = options;

  const { tokens } = await __.getConfig();
  const { access_token } = await __.freshTokens(tokens);

  const url = `${baseUrl}/${path}${queryString({ ...query })}`;

  // A plain object is sent as JSON. The caller sets the Content-Type of a raw
  // body
  const isJson = _.isPlainObject(body);
  // A passed header replaces a default header, the authentication included
  const defaultHeaders = {
    Authorization: `Bearer ${access_token}`,
    ...(isJson && { 'Content-Type': 'application/json' }),
  };

  let response;
  try {
    response = await __.fetch(url, {
      method,
      headers: { ...defaultHeaders, ...headers },
      body: isJson ? JSON.stringify(body) : body,
    });
  } catch (error) {
    throw firostError(errorCode, error.message);
  }

  // Read the body as text, so that an empty body does not throw
  const text = await response.text();

  // A token granted before a scope was added is rejected with a 403
  const isScopeMissing =
    response.status === 403 &&
    _.includes(text, 'ACCESS_TOKEN_SCOPE_INSUFFICIENT');
  if (response.status === 401 || isScopeMissing) {
    throw firostError(
      'GOOGLE_LOGIN_REQUIRED',
      loginCommand(configInternals.account),
    );
  }
  if (!response.ok) {
    throw firostError(errorCode, `${response.status} ${text}`);
  }

  // Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError(errorCode, text);
  }
}

__ = {
  /**
   * Refresh the tokens that are about to expire. The refresh is best-effort:
   * a failure keeps the current tokens
   * @param {object} tokens - The current tokens
   * @returns {Promise<object>} The tokens to authenticate with
   */
  async freshTokens(tokens) {
    const isValid = tokens.expires_at - Date.now() > EXPIRY_MARGIN;
    if (isValid) {
      return tokens;
    }
    try {
      return await __.refreshTokens(tokens);
    } catch {
      return tokens;
    }
  },
  fetch,
  getConfig,
  refreshTokens,
};
