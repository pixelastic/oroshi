import { _, pMap } from 'golgoth';
import { google } from 'googleapis';
import { convert } from 'html-to-text';

export let __;

/**
 * Read mails through the Gmail API
 */
export const gmailMessages = {
  /**
   * List messages matching a Gmail query
   * @param {object} auth - Authenticated OAuth2 client
   * @param {object} options - Search options
   * @param {string} options.query - Gmail search query
   * @param {number} options.limit - Maximum number of messages
   * @returns {object[]} Normalized messages { id, from, subject, date, snippet }
   */
  async list(auth, { query, limit }) {
    const ids = await __.fetchIds(auth, { query, limit });
    const messages = await pMap(ids, ({ id }) => __.fetchMessage(auth, id));
    return _.map(messages, __.normalize);
  },

  /**
   * Get one full message, with its decoded body
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} id - Message id
   * @returns {object} Normalized message { id, from, to, subject, date, snippet, body }
   */
  async get(auth, id) {
    const message = await __.fetchFull(auth, id);
    return {
      ...__.normalize(message),
      to: header(message, 'To'),
      body: extractBody(message.payload),
    };
  },
};

__ = {
  /**
   * Fetch ids of messages matching the query. The query goes untouched to
   * the Gmail API q parameter
   * @param {object} auth - Authenticated OAuth2 client
   * @param {object} options - Search options
   * @param {string} options.query - Gmail search query
   * @param {number} options.limit - Maximum number of messages
   * @returns {object[]} Array of { id, threadId }
   */
  async fetchIds(auth, { query, limit }) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.messages.list({
      userId: 'me',
      q: query,
      maxResults: limit,
    });
    return response.data.messages || [];
  },

  /**
   * Fetch one message, headers only
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} id - Message id
   * @returns {object} Gmail message resource
   */
  async fetchMessage(auth, id) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.messages.get({
      userId: 'me',
      id,
      format: 'metadata',
      metadataHeaders: ['From', 'Subject', 'Date'],
    });
    return response.data;
  },

  /**
   * Fetch one message, with its full payload
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} id - Message id
   * @returns {object} Gmail message resource
   */
  async fetchFull(auth, id) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.messages.get({
      userId: 'me',
      id,
      format: 'full',
    });
    return response.data;
  },

  /**
   * Convert a Gmail message resource to a flat message
   * @param {object} message - Gmail message resource
   * @returns {object} { id, from, subject, date, snippet }
   */
  normalize(message) {
    return {
      id: message.id,
      from: header(message, 'From'),
      subject: header(message, 'Subject'),
      date: header(message, 'Date'),
      snippet: message.snippet || '',
    };
  },
};

/**
 * Read one header of a message, case-insensitively
 * @param {object} message - Gmail message resource
 * @param {string} name - Header name
 * @returns {string} Header value, or an empty string
 */
function header(message, name) {
  return _.chain(message.payload?.headers)
    .find((h) => _.toLower(h.name) === _.toLower(name))
    .get('value', '')
    .value();
}

/**
 * Extract the readable body of a message payload. Prefers text/plain and
 * falls back to HTML converted to text
 * @param {object} payload - Gmail message payload
 * @returns {string} Body text, or an empty string if there is none
 */
function extractBody(payload) {
  const plain = findPart(payload, 'text/plain');
  if (plain) {
    return decode(plain.body.data);
  }
  const html = findPart(payload, 'text/html');
  if (html) {
    return convert(decode(html.body.data), {
      wordwrap: false,
      selectors: [{ selector: 'img', format: 'skip' }],
    });
  }
  return '';
}

/**
 * Find the first part with the given mime type, walking nested multiparts
 * @param {object} part - Gmail message part
 * @param {string} mimeType - Mime type to find
 * @returns {object|undefined} The part, if it has inline data
 */
function findPart(part, mimeType) {
  if (!part) {
    return undefined;
  }
  if (part.mimeType === mimeType && part.body?.data) {
    return part;
  }
  return _.chain(part.parts)
    .map((child) => findPart(child, mimeType))
    .find()
    .value();
}

/**
 * Decode base64url content as UTF-8
 * @param {string} data - base64url string
 * @returns {string} Decoded text
 */
function decode(data) {
  return Buffer.from(data, 'base64url').toString('utf8');
}
