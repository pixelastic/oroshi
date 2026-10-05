import { _, pMap } from 'golgoth';
import { google } from 'googleapis';
import { gmailMessages } from './messages.js';
import { gmailSenderName } from './senderName.js';

export let __;

/**
 * Read threads through the Gmail API
 */
export const gmailThreads = {
  /**
   * Get every message of a thread, with its decoded body
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} threadId - Thread id
   * @returns {object[]} Normalized messages { id, from, to, subject, date, snippet, body, attachments }, oldest first, or an empty array for a thread without messages
   */
  async get(auth, threadId) {
    const thread = await __.fetchThread(auth, threadId);
    return _.chain(thread.messages)
      .sortBy((message) => Number(message.internalDate))
      .map(gmailMessages.parseFull)
      .value();
  },

  /**
   * List threads matching a Gmail query, as summaries
   * @param {object} auth - Authenticated OAuth2 client
   * @param {object} options - Search options
   * @param {string} options.query - Gmail search query
   * @param {number} options.limit - Maximum number of threads
   * @returns {object[]} Summaries { threadId, unread, date, count, authors, subject, snippet }, unread threads first, then read threads
   */
  async list(auth, { query, limit }) {
    const ids = await __.fetchThreadIds(auth, { query, limit });
    const threads = await pMap(ids, ({ id }) =>
      __.fetchThreadMetadata(auth, id),
    );
    const summaries = _.chain(threads)
      .reject((thread) => _.isEmpty(thread.messages))
      .map(summarize)
      .value();
    return _.chain(summaries).partition('unread').flatten().value();
  },
};

__ = {
  /**
   * Fetch ids of threads matching the query. The query goes untouched to
   * the Gmail API q parameter
   * @param {object} auth - Authenticated OAuth2 client
   * @param {object} options - Search options
   * @param {string} options.query - Gmail search query
   * @param {number} options.limit - Maximum number of threads
   * @returns {object[]} Array of { id }
   */
  async fetchThreadIds(auth, { query, limit }) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.threads.list({
      userId: 'me',
      q: query,
      maxResults: limit,
    });
    return response.data.threads || [];
  },

  /**
   * Fetch one thread, with the headers of its messages only
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} id - Thread id
   * @returns {object} Gmail thread resource
   */
  async fetchThreadMetadata(auth, id) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.threads.get({
      userId: 'me',
      id,
      format: 'metadata',
      metadataHeaders: ['From', 'Subject', 'Date'],
    });
    return response.data;
  },

  /**
   * Fetch one thread, with the full payload of its messages
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} id - Thread id
   * @returns {object} Gmail thread resource
   */
  async fetchThread(auth, id) {
    const gmail = google.gmail({ version: 'v1', auth });
    const response = await gmail.users.threads.get({
      userId: 'me',
      id,
      format: 'full',
    });
    return response.data;
  },
};

/**
 * Summarize a thread of at least one message
 * @param {object} thread - Gmail thread resource, with its messages
 * @returns {object} { threadId, unread, date, count, authors, subject, snippet }
 */
function summarize(thread) {
  const messages = _.chain(thread.messages)
    .sortBy((message) => Number(message.internalDate))
    .map(gmailMessages.parseMetadata)
    .value();
  const latest = _.last(messages);
  const [unreadMessages, readMessages] = _.partition(messages, 'unread');
  const authors = _.chain([...unreadMessages, ...readMessages])
    .map((message) => gmailSenderName(message.from))
    .uniq()
    .value();
  return {
    threadId: thread.id,
    unread: !_.isEmpty(unreadMessages),
    date: latest.date,
    count: messages.length,
    authors,
    subject: latest.subject,
    snippet: latest.snippet,
  };
}
