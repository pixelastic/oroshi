import { _ } from 'golgoth';

/**
 * Compute the addressing and the threading headers of a reply to a Mail
 * @param {object} mail - The Mail to reply to
 * @param {string} mail.from - From header
 * @param {string} mail.replyTo - Reply-To header, or an empty string
 * @param {string} mail.subject - Subject header
 * @param {string} mail.messageId - Message-ID header
 * @param {string} mail.references - References header, or an empty string
 * @returns {object} { to, subject, inReplyTo, references }
 */
export function buildReply(mail) {
  const { from, replyTo, subject, messageId, references } = mail;

  return {
    to: replyTo || from,
    subject: /^re:/i.test(subject) ? subject : `Re: ${subject}`,
    inReplyTo: messageId,
    references: _.chain([references, messageId]).compact().join(' ').value(),
  };
}
