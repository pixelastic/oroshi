import { _ } from 'golgoth';
import { google } from 'googleapis';
import { gmailMessages } from './messages.js';

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
};

__ = {
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
