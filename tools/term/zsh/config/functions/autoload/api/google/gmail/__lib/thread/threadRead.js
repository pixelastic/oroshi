import { _ } from 'golgoth';
import { firostError } from 'firost';
import { formatThread } from './formatThread.js';
import { getThread } from './getThread.js';

export let __;

/**
 * Read a Thread as a whole
 * @param {object} options - Read options
 * @param {string} options.threadId - Id of the Thread. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The Thread as { threadId, subject, unread, messages }, its Messages formatted, oldest first
 */
export async function threadRead(options) {
  const { threadId } = options;

  if (!threadId) {
    throw firostError('GMAIL_THREAD_ID_MISSING', 'Pass the id of a Thread');
  }

  const response = await __.getThread(threadId, {
    query: { format: 'full' },
  });

  return _.pick(__.formatThread(response), [
    'threadId',
    'subject',
    'unread',
    'messages',
  ]);
}

__ = {
  formatThread,
  getThread,
};
