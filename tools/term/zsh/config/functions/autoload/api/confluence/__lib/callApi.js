import { firostError } from 'firost';
import { queryString } from '@oroshi/api-shared/queryString.js';
import { getConfig } from './getConfig.js';

export let __;

const GATEWAY_URL = 'https://api.atlassian.com/ex/confluence';

/**
 * Call the Confluence API, through the Atlassian gateway
 * @param {string} path - Path of the endpoint, from the v2 API
 * @param {object} [options] - Request options
 * @param {string} [options.baseUrl] - Base URL of the endpoint, for an endpoint served by another API
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request
 * @param {object} [options.query] - Query parameters, merged over the defaults
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  const { method = 'GET', body, query, headers } = options;

  const { email, token, cloudId } = await __.getConfig();
  const { baseUrl = `${GATEWAY_URL}/${cloudId}/wiki/api/v2` } = options;

  // A passed query key replaces a default key
  const defaultQuery = {};
  const search = queryString({ ...defaultQuery, ...query });
  const url = `${baseUrl}/${path}${search}`;

  // A passed header replaces a default header, the authentication included
  const credentials = Buffer.from(`${email}:${token}`).toString('base64');
  const defaultHeaders = {
    Authorization: `Basic ${credentials}`,
    'Content-Type': 'application/json',
  };

  let response;
  try {
    response = await __.fetch(url, {
      method,
      headers: { ...defaultHeaders, ...headers },
      body: body && JSON.stringify(body),
    });
  } catch (error) {
    throw firostError('CONFLUENCE_REQUEST_FAILED', error.message);
  }

  // Read the body as text, so that an empty body does not throw
  const text = await response.text();

  // The token is rejected
  if (response.status === 401) {
    throw firostError(
      'CONFLUENCE_REQUEST_FAILED',
      '401 Unauthorized, the CONFLUENCE_TOKEN token is expired or wrong',
    );
  }

  // The page does not exist, or the token cannot see it
  if (response.status === 404) {
    throw firostError(
      'CONFLUENCE_REQUEST_FAILED',
      '404 Page not found or restricted',
    );
  }

  if (!response.ok) {
    throw firostError(
      'CONFLUENCE_REQUEST_FAILED',
      `${response.status} ${text}`,
    );
  }

  // Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError('CONFLUENCE_REQUEST_FAILED', text);
  }
}

__ = {
  fetch,
  getConfig,
};
