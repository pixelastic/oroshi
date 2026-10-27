import { _, dayjs } from 'golgoth';
import { senderName } from '../senderName.js';
import { formatMessage } from './formatMessage.js';

export let __;

/**
 * Format one Thread, to give every command the same output
 * @param {object} response - The Thread, as returned by the Gmail API
 * @returns {object} The Thread as { threadId, subject, unread, messages }, plus the fields of the flat list format: { date, count, authors, snippet }
 */
export function formatThread(response) {
  const entries = _.chain(response.messages)
    .sortBy((message) => Number(message.internalDate))
    .map(__.toEntry)
    .value();
  // Like the Gmail inbox, show the last Message received in the inbox, not the
  // replies sent from it
  const shown = _.findLast(entries, 'inbox') || _.last(entries);
  const [unreadEntries, readEntries] = _.partition(entries, 'unread');
  const authors = _.chain([...unreadEntries, ...readEntries])
    .map((entry) => senderName(entry.message.from))
    .uniq()
    .value();

  return {
    threadId: response.id,
    subject: shown.message.subject,
    unread: !_.isEmpty(unreadEntries),
    messages: _.map(entries, 'message'),
    date: __.isoDate(_.last(entries).message.date),
    count: entries.length,
    authors,
    snippet: shown.message.snippet,
  };
}

__ = {
  /**
   * Pair a formatted Message with its labels
   * @param {object} message - Gmail message resource
   * @returns {object} { message, unread, inbox }, message being the formatted Message
   */
  toEntry(message) {
    return {
      message: formatMessage(message),
      unread: _.includes(message.labelIds, 'UNREAD'),
      inbox: _.includes(message.labelIds, 'INBOX'),
    };
  },

  /**
   * Format a Date header as an ISO 8601 date
   * @param {string} date - Date header
   * @returns {string} ISO 8601 date, or an empty string if invalid
   */
  isoDate(date) {
    const parsed = dayjs(date);
    return parsed.isValid() ? parsed.toISOString() : '';
  },
};
