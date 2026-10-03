import { _ } from 'golgoth';

/**
 * Format messages as a JSON array, ready to pipe to jq
 * @param {object[]} messages - Normalized messages
 * @returns {string} JSON array of { id, from, subject, date, snippet }
 */
export function gmailFormatJson(messages) {
  const items = _.map(messages, (message) =>
    _.pick(message, ['id', 'from', 'subject', 'date', 'snippet']),
  );
  return JSON.stringify(items, null, 2);
}
