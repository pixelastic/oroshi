import { _ } from 'golgoth';
import { simpleParser } from 'mailparser';
import { getDraft } from './getDraft.js';

export let __;

// The raw builder wraps the HTML in this div, loading unwraps it
const HTML_WRAPPER = /^<div dir="ltr">([\s\S]*)<\/div>$/;

/**
 * Load a Draft as the fields and attachments that the raw builder accepts
 * @param {string} draftId - Id of the Draft
 * @returns {Promise<object>} { draftId, threadId, from, to, cc, subject, inReplyTo, references, text, html, attachments }. Throws GMAIL_DRAFT_NOT_FOUND if the Draft does not exist
 */
export async function loadDraft(draftId) {
  const draft = await __.getDraft(draftId, 'raw');
  const mail = await simpleParser(
    Buffer.from(draft.message.raw, 'base64url'),
    // Keep cid: links as they are, they point to the inline attachments
    { keepCidLinks: true },
  );

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    from: _.get(mail, 'from.text', ''),
    to: _.get(mail, 'to.text', ''),
    cc: _.get(mail, 'cc.text', ''),
    subject: mail.subject,
    inReplyTo: mail.inReplyTo,
    references: _.isEmpty(mail.references)
      ? undefined
      : mail.references.join(' '),
    text: mail.text,
    html: mail.html ? mail.html.replace(HTML_WRAPPER, '$1') : undefined,
    attachments: _.map(mail.attachments, (attachment) =>
      _.pickBy(
        {
          filename: attachment.filename,
          contentType: attachment.contentType,
          content: attachment.content,
          cid: attachment.cid,
          contentDisposition: attachment.contentDisposition,
        },
        (value) => !_.isUndefined(value),
      ),
    ),
  };
}

__ = {
  getDraft,
};
