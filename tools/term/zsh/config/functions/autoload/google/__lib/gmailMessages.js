import { _, pMap } from 'golgoth';
import { google } from 'googleapis';

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
   * Convert a Gmail message resource to a flat message
   * @param {object} message - Gmail message resource
   * @returns {object} { id, from, subject, date, snippet }
   */
  normalize(message) {
    const header = (name) =>
      _.chain(message.payload?.headers)
        .find((h) => _.toLower(h.name) === _.toLower(name))
        .get('value', '')
        .value();
    return {
      id: message.id,
      from: header('From'),
      subject: header('Subject'),
      date: header('Date'),
      snippet: message.snippet || '',
    };
  },
};
