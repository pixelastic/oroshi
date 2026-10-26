import { _ } from 'golgoth';
import MailComposer from 'nodemailer/lib/mail-composer/index.js';

/**
 * Build the raw mail of a draft, ready for the Gmail API
 * @param {object} options - Mail options
 * @param {string} [options.from] - Sender, an alias of the user
 * @param {string} options.to - Recipient
 * @param {string} [options.cc] - Copies, or an empty string
 * @param {string} options.subject - Subject, encoded when it is not ASCII
 * @param {string} options.body - Body, sent as text/plain, and as HTML when there is a quote
 * @param {object} [options.quote] - Quote of the Mail replied to, as { html, text }. Makes the mail multipart/alternative
 * @param {string} [options.inReplyTo] - Message-ID of the Mail replied to
 * @param {string} [options.references] - References header of a reply
 * @returns {Promise<string>} The mail, encoded in base64url
 */
export async function buildRaw(options) {
  const { from, to, cc, subject, body, quote, inReplyTo, references } = options;
  const mail = await new MailComposer({
    from,
    to,
    cc: cc || undefined,
    subject,
    text: quote ? `${body}\n\n${quote.text}` : body,
    html: quote
      ? `<div dir="ltr">${_.chain(body).escape().replace(/\r?\n/g, '<br>').value()}</div><br>${quote.html}`
      : undefined,
    inReplyTo,
    references,
  })
    .compile()
    .build();
  return mail.toString('base64url');
}
