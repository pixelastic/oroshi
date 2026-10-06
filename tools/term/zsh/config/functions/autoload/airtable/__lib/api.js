import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

const API_URL = 'https://api.airtable.com/v0';

/**
 * Call the Airtable API with the Read token or the Write token
 * @param {object} options - Call options
 * @param {string} options.mode - "read" or "write", picks the token
 * @param {string} options.method - HTTP method
 * @param {string} options.base - Base alias (DevRel) or Base ID (appXXX)
 * @param {string} options.path - Path inside the Base, with its query string
 * @param {object} [options.body] - JSON body to send
 * @returns {Promise<object>} The parsed response body
 */
export async function airtableApi(options) {
  const { mode, method, base, path, body } = options;

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

  const baseId = __.resolveBase(base);

  const headers = { Authorization: `Bearer ${token}` };
  const request = { method, headers };
  if (body) {
    headers['Content-Type'] = 'application/json';
    request.body = JSON.stringify(body);
  }

  const response = await __.fetch(`${API_URL}/${baseId}/${path}`, request);
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
   * A Base ID passes through, anything else is a Base alias
   * @param {string} base - Base alias or Base ID
   * @returns {string} The Base ID
   */
  resolveBase(base) {
    if (_.startsWith(base, 'app')) {
      return base;
    }

    const baseVariable = `AIRTABLE_BASE_${_.toUpper(base)}`;
    const baseId = process.env[baseVariable];
    if (!baseId) {
      throw firostError(
        'AIRTABLE_API_UNKNOWN_BASE',
        `${baseVariable} is not set`,
      );
    }
    return baseId;
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
