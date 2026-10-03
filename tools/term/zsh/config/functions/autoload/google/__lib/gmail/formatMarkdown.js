import { _ } from 'golgoth';

const HEADERS = [
  { label: 'From', key: 'from' },
  { label: 'To', key: 'to' },
  { label: 'Date', key: 'date' },
  { label: 'Subject', key: 'subject' },
];

/**
 * Format one mail as Markdown: headers first, then the body
 * @param {object} message - Message { from, to, date, subject, body }
 * @returns {string} Markdown
 */
export function gmailFormatMarkdown(message) {
  const headers = _.chain(HEADERS)
    .filter(({ key }) => !_.isEmpty(message[key]))
    .map(({ label, key }) => `**${label}:** ${message[key]}`)
    .join('  \n')
    .value();
  return `${headers}\n\n${message.body}`;
}
