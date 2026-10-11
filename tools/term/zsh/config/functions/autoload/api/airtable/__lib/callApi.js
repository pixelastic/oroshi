import { _ } from 'golgoth';
import { firostError } from 'firost';
import { getConfig } from './getConfig.js';

export let __;

const BASE_URL = 'https://api.airtable.com/v0';

/**
 * Call the Airtable API
 * @param {string} path - Path of the endpoint, or an absolute URL for another host
 * @param {object} [options] - Request options
 * @param {string} [options.method] - HTTP method
 * @param {object} [options.body] - Body of the request
 * @param {object} [options.query] - Query parameters, merged over the defaults. A list is sent as `key[]`, a list of objects as `key[index][property]`. Empty values are skipped
 * @param {object} [options.headers] - Headers, merged over the defaults
 * @returns {Promise<object|string>} The response of the API, or the empty body
 */
export async function callApi(path, options = {}) {
  const { method = 'GET', body, query, headers } = options;

  const { token } = await __.getConfig();

  // A passed query key replaces a default key
  const defaultQuery = {};
  const search = __.queryString({ ...defaultQuery, ...query });
  const endpoint = _.startsWith(path, 'https://')
    ? path
    : `${BASE_URL}/${path}`;
  const url = `${endpoint}${search}`;

  // A passed header replaces a default header, the authentication included
  const defaultHeaders = {
    Authorization: `Bearer ${token}`,
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
    throw firostError('AIRTABLE_REQUEST_FAILED', error.message);
  }

  // Read the body as text, so that an empty body does not throw
  const text = await response.text();

  if (!response.ok) {
    throw firostError('AIRTABLE_REQUEST_FAILED', text);
  }

  // Return an empty body as it is, parse anything else
  if (!text) {
    return text;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw firostError('AIRTABLE_REQUEST_FAILED', text);
  }
}

__ = {
  /**
   * Serialize query parameters the way Airtable expects them
   * @param {object} [query] - Query parameters
   * @returns {string} The query string with its leading ?, or an empty string
   */
  queryString(query) {
    const params = _.chain(query)
      .flatMap((value, key) => __.queryParams(key, value))
      .join('&')
      .value();
    return params ? `?${params}` : '';
  },
  /**
   * Serialize one query parameter
   * @param {string} key - Parameter name
   * @param {*} value - Scalar, list of scalars or list of objects
   * @returns {string[]} One `key=value` entry per value, none for an empty one
   */
  queryParams(key, value) {
    if (_.isNil(value)) {
      return [];
    }
    if (!_.isArray(value)) {
      return [`${key}=${encodeURIComponent(value)}`];
    }
    return _.flatMap(value, (item, index) =>
      _.isPlainObject(item)
        ? _.map(
            item,
            (property, name) =>
              `${encodeURIComponent(`${key}[${index}][${name}]`)}=${encodeURIComponent(property)}`,
          )
        : [`${encodeURIComponent(`${key}[]`)}=${encodeURIComponent(item)}`],
    );
  },
  fetch,
  getConfig,
};
