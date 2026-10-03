import { _ } from 'golgoth';

/**
 * Format a message as one raw line: id▮subject▮first line of content
 * @param {object} message - Normalized message { id, subject, snippet }
 * @returns {string} Raw line
 */
export function gmailFormatRaw(message) {
  const subject = _.chain(message.subject).split(/\r?\n/).join(' ').value();
  const firstLine = _.chain(message.snippet).split(/\r?\n/).first().value();
  return [message.id, subject, firstLine].join('▮');
}
