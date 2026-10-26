import { _ } from 'golgoth';
import { firostError, read } from 'firost';
import { callApi } from '../callApi.js';
import { extractBodies } from '../extractBodies.js';
import { header } from '../header.js';
import { buildQuote } from './buildQuote.js';
import { buildRaw } from './buildRaw.js';
import { buildReply } from './buildReply.js';
import { getAliases } from './getAliases.js';
import { renderBody } from './renderBody.js';

export let __;

/**
 * Create a draft in Gmail, with the last Mail quoted when it is a reply
 * @param {object} options - Draft options
 * @param {string} [options.account] - Name of the account, to read its aliases
 * @param {string} [options.messageId] - Id of the Message to reply to. The reply goes to its last Mail, in its thread
 * @param {string} [options.to] - Recipient. Overrides the reply. Throws GMAIL_TO_MISSING if empty without messageId
 * @param {string} [options.subject] - Subject. Overrides the reply. Throws GMAIL_SUBJECT_MISSING if empty without messageId
 * @param {string} [options.body] - Body, sent as text/plain, and as HTML when it is a reply. Excludes bodyFile
 * @param {string} [options.bodyFile] - Path of a file holding the body. A .md file is also sent as HTML. Excludes body. Throws GMAIL_BODY_CONFLICT if both are given, GMAIL_BODY_MISSING if none is
 * @returns {Promise<object>} { draftId, threadId, url }, the url opening the draft in Gmail
 */
export async function draftCreate(options) {
  const { messageId, bodyFile, account } = options;

  const reply = messageId ? await __.readReply(messageId, account) : {};
  const to = options.to || reply.to;
  const subject = options.subject || reply.subject;
  const { from, cc, quote, inReplyTo, references } = reply;

  if (!to) {
    throw firostError('GMAIL_TO_MISSING', 'Pass the recipient with --to');
  }
  if (!subject) {
    throw firostError('GMAIL_SUBJECT_MISSING', 'Pass the --subject');
  }

  const file = bodyFile && {
    path: bodyFile,
    content: await __.read(bodyFile),
  };
  const { text, html } = __.renderBody({ body: options.body, file });

  const raw = await __.buildRaw({
    from,
    to,
    cc,
    subject,
    body: text,
    html,
    quote,
    inReplyTo,
    references,
  });
  const draft = await __.callApi('drafts', {
    method: 'POST',
    body: { message: { raw, ...(messageId && { threadId: messageId }) } },
  });

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    url: `https://mail.google.com/mail/u/0/#drafts?compose=${draft.message.id}`,
  };
}

__ = {
  /**
   * Compute the reply to the last Mail of a Message
   * @param {string} messageId - Id of the Message
   * @param {string} [account] - Name of the account, to read its aliases
   * @returns {Promise<object>} { from, to, cc, subject, quote, inReplyTo, references }
   */
  async readReply(messageId, account) {
    const aliases = __.getAliases(account);
    const thread = await __.callApi(`threads/${messageId}`, {
      query: { format: 'full' },
    });
    const last = _.maxBy(thread.messages, (mail) => Number(mail.internalDate));
    const reply = buildReply(
      {
        from: header(last, 'From'),
        replyTo: header(last, 'Reply-To'),
        to: header(last, 'To'),
        cc: header(last, 'Cc'),
        subject: header(last, 'Subject'),
        messageId: header(last, 'Message-ID'),
        references: header(last, 'References'),
      },
      aliases,
    );
    const quote = __.buildQuote({
      date: header(last, 'Date'),
      from: header(last, 'From'),
      ...__.extractBodies(last.payload),
    });
    return { ...reply, quote };
  },
  buildQuote,
  buildRaw,
  callApi,
  extractBodies,
  getAliases,
  read,
  renderBody,
};
