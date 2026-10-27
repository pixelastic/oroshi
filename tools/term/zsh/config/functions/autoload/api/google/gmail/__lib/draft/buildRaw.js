import MailComposer from 'nodemailer/lib/mail-composer/index.js';

/**
 * Build the raw mail of a draft, ready for the Gmail API
 * @param {object} options - Mail options
 * @param {string} [options.from] - Sender, an alias of the user
 * @param {string} options.to - Recipient
 * @param {string} [options.cc] - Copies, or an empty string
 * @param {string} options.subject - Subject, encoded when it is not ASCII
 * @param {string} options.body - Body, sent as text/plain
 * @param {string} [options.html] - HTML of the body. Makes the mail multipart/alternative
 * @param {string} [options.inReplyTo] - Message-ID of the Message replied to
 * @param {string} [options.references] - References header of a reply
 * @returns {Promise<string>} The mail, encoded in base64url
 */
export async function buildRaw(options) {
  const { from, to, cc, subject, body, html, inReplyTo, references } = options;
  const mail = await new MailComposer({
    from,
    to,
    cc: cc || undefined,
    subject,
    text: body,
    html: html && `<div dir="ltr">${html}</div>`,
    inReplyTo,
    references,
  })
    .compile()
    .build();
  return mail.toString('base64url');
}
