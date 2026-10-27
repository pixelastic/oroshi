import { _ } from 'golgoth';
import { separators } from './separators.js';

/**
 * Parse a raw row back into a Message
 * @param {string} line - Raw row, as printed by gmail-thread-list-raw
 * @returns {Promise<object>} { id, date, count, authors, subject, snippet, unread }, with date in ISO 8601
 */
export async function parseRaw(line) {
  const { field, list } = await separators();
  const [id, date, count, authors, subject, snippet, unread] =
    line.split(field);
  return {
    id,
    date,
    count: Number(count),
    authors: _.isEmpty(authors) ? [] : authors.split(list),
    subject,
    snippet,
    unread: unread === 'true',
  };
}
