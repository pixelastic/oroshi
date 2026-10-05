import { _, dayjs } from 'golgoth';
import { gmailSeparators } from './separators.js';

/**
 * Format a thread as one raw line: threadId▮unread▮date▮count▮authors▮subject▮snippet
 * Newlines become spaces and separators are removed from every field. Authors are joined with ▯
 * @param {object} thread - Thread summary { threadId, unread, date, count, authors, subject, snippet }
 * @returns {Promise<string>} Raw line
 */
export async function gmailFormatRaw(thread) {
  const { field, list } = await gmailSeparators();
  const clean = (text) =>
    _.chain(text)
      .replace(/\s*[\r\n]+\s*/g, ' ')
      .split(field)
      .join('')
      .split(list)
      .join('')
      .value();

  return [
    clean(thread.threadId),
    thread.unread ? '1' : '0',
    isoDate(thread.date),
    thread.count,
    _.chain(thread.authors).map(clean).join(list).value(),
    clean(thread.subject),
    clean(thread.snippet),
  ].join(field);
}

/**
 * Format a Date header as an ISO 8601 date
 * @param {string} date - Date header
 * @returns {string} ISO 8601 date, or an empty string if invalid
 */
function isoDate(date) {
  const parsed = dayjs(date);
  return parsed.isValid() ? parsed.toISOString() : '';
}
