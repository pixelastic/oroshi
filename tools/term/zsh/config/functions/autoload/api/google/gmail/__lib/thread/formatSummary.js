import { formatThread } from './formatThread.js';

/**
 * Format one Thread as the flat summary of the search and list commands
 * @param {object} response - The Thread, as returned by the Gmail API
 * @returns {object} The summary as { id, date, count, authors, subject, snippet, unread }
 */
export function formatSummary(response) {
  const { threadId, date, count, authors, subject, snippet, unread } =
    formatThread(response);
  return { id: threadId, date, count, authors, subject, snippet, unread };
}
