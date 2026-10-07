import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

const HOST_URLS = {
  api: 'https://api.airtable.com/v0',
  content: 'https://content.airtable.com/v0',
  schema: 'https://api.airtable.com/v0/meta/bases',
};

/**
 * Call the Airtable API with the Read token or the Write token
 * @param {object} options - Call options
 * @param {string} options.mode - "read" or "write", picks the token
 * @param {string} options.method - HTTP method
 * @param {string} [options.base] - Base ID (appXXX). Only the "schema" host can go without one, to list the Bases
 * @param {string|string[]} [options.path] - Path segments inside the Base, such as a Table name. Each segment is URL-encoded
 * @param {object} [options.query] - Query parameters. A list sends each item as `key[]`, a list of objects as `key[index][property]`. Empty values are skipped
 * @param {object} [options.body] - JSON body to send
 * @param {string} [options.host] - "api", "content" for file uploads, or "schema" for Bases and Tables
 * @returns {Promise<object>} The parsed response body
 */
export async function airtableApi(options) {
  const { mode, method, base, path, query, body, host = 'api' } = options;

  // Return early if the mode is neither read nor write
  if (!['read', 'write'].includes(mode)) {
    throw firostError(
      'AIRTABLE_API_INVALID_MODE',
      `mode must be read or write, got '${mode}'`,
    );
  }

  // Return early if the token of this mode is missing
  const tokenVariable = `AIRTABLE_TOKEN_${_.toUpper(mode)}`;
  const token = process.env[tokenVariable];
  if (!token) {
    throw firostError(
      'AIRTABLE_API_MISSING_TOKEN',
      `${tokenVariable} is not set`,
    );
  }

  const headers = { Authorization: `Bearer ${token}` };
  const request = { method, headers };
  if (body) {
    headers['Content-Type'] = 'application/json';
    request.body = JSON.stringify(body);
  }

  const url = _.chain([HOST_URLS[host], base, __.encodePath(path)])
    .compact()
    .join('/')
    .value();
  const response = await __.fetch(`${url}${__.queryString(query)}`, request);
  const content = await __.readJson(response);
  if (response.ok) {
    return content;
  }

  throw firostError(
    'AIRTABLE_API_ERROR',
    __.errorMessage(content, response.status),
  );
}

__ = {
  /**
   * URL-encode each segment of a path
   * @param {string|string[]} [path] - One segment, or a list of segments
   * @returns {string} Encoded segments joined with a slash, empty without a path
   */
  encodePath(path) {
    return _.chain(path)
      .castArray()
      .compact()
      .map(encodeURIComponent)
      .join('/')
      .value();
  },
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
              `${key}[${index}][${name}]=${encodeURIComponent(property)}`,
          )
        : [`${key}[]=${encodeURIComponent(item)}`],
    );
  },
  /**
   * Parse the body of a response. A gateway error can send a body that is not
   * JSON, which then counts as an empty body
   * @param {Response} response - Response to read
   * @returns {Promise<object>} The parsed body, or an empty object
   */
  async readJson(response) {
    try {
      return await response.json();
    } catch (_error) {
      return {};
    }
  },
  /**
   * Airtable sends the error as an object with a message, a type, or as a bare
   * string
   * @param {object} content - Parsed error response
   * @param {number} status - HTTP status
   * @returns {string} The most precise message available
   */
  errorMessage(content, status) {
    const error = content?.error;
    return error?.message || error?.type || error || `HTTP ${status}`;
  },
  fetch,
};
