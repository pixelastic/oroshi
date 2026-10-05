import { _ } from 'golgoth';
import { gmailSeparators } from './separators.js';

/**
 * Parse a raw line back into a thread summary
 * @param {string} line - Raw line, as formatted by gmailFormatRaw
 * @returns {Promise<object>} { threadId, unread, date, count, authors, subject, snippet, lastMessageId, lastMessageDate }, with date in ISO 8601
 */
export async function gmailParseRaw(line) {
  const separators = await gmailSeparators();
  const [
    threadId,
    unread,
    date,
    count,
    authors,
    subject,
    snippet,
    lastMessageId,
    lastMessageDate,
  ] = line.split(separators.field);
  return {
    threadId,
    unread: unread === '1',
    date,
    count: Number(count),
    authors: _.isEmpty(authors) ? [] : authors.split(separators.list),
    subject,
    snippet,
    lastMessageId,
    lastMessageDate,
  };
}
