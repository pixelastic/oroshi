import { firostError } from 'firost';
import { queryString } from '@oroshi/api-shared/queryString.js';
import { getConfig } from './getConfig.js';

export let __;

const BASE_URL = 'https://api.notion.com/v1';
const API_VERSION = '2026-03-11';

/**
 * Call the Notion API
 * @param {string} path - Path of the endpoint
 * @param {object} [options] - Request options
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request
 * @param {object} [options.query] - Query parameters, merged over the defaults
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  const { method = 'GET', body, query, headers } = options;

  const { token } = await __.getConfig();

  // A passed query key replaces a default key
  const defaultQuery = {};
  const search = queryString({ ...defaultQuery, ...query });
  const url = `${BASE_URL}/${path}${search}`;

  // A passed header replaces a default header, the authentication included
  const defaultHeaders = {
    Authorization: `Bearer ${token}`,
    'Notion-Version': API_VERSION,
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
    throw firostError('NOTION_REQUEST_FAILED', error.message);
  }

  // Read the body as text, so that an empty body does not throw
  const text = await response.text();

  if (!response.ok) {
    throw firostError('NOTION_REQUEST_FAILED', `${response.status} ${text}`);
  }

  // Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError('NOTION_REQUEST_FAILED', text);
  }
}

__ = {
  fetch,
  getConfig,
};
