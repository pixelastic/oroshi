import { _ } from 'golgoth';
import { firostError, read } from 'firost';
import { callApi } from '../callApi.js';
import { header } from '../header.js';
import { getThread } from '../thread/getThread.js';
import { buildRaw } from './buildRaw.js';
import { buildReply } from './buildReply.js';
import { getAliases } from './getAliases.js';
import { renderBody } from './renderBody.js';

export let __;

/**
 * Create a draft in Gmail, replying to the last Message of a Thread when given a threadId
 * @param {object} options - Draft options
 * @param {string} [options.threadId] - Id of the Thread to reply to. The reply goes to its last Message
 * @param {string} [options.to] - Recipient. Overrides the reply. Throws GMAIL_TO_MISSING if empty without threadId
 * @param {string} [options.subject] - Subject. Overrides the reply. Throws GMAIL_SUBJECT_MISSING if empty without threadId
 * @param {string} [options.body] - Body, sent as text/plain. Excludes bodyFile
 * @param {string} [options.bodyFile] - Path of a file holding the body. A .md file is also sent as HTML. Excludes body. Throws GMAIL_BODY_CONFLICT if both are given, GMAIL_BODY_MISSING if none is
 * @returns {Promise<object>} { draftId, threadId, url }, the url opening the draft in Gmail
 */
export async function draftCreate(options) {
  const { threadId, bodyFile } = options;

  const reply = threadId ? await __.readReply(threadId) : {};
  const to = options.to || reply.to;
  const subject = options.subject || reply.subject;
  const { from, cc, inReplyTo, references } = reply;

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

  const mime = await __.buildRaw({
    from,
    to,
    cc,
    subject,
    body: text,
    html,
    inReplyTo,
    references,
  });
  const draft = await __.callApi('drafts', {
    method: 'POST',
    body: {
      message: {
        raw: mime.toString('base64url'),
        ...(threadId && { threadId }),
      },
    },
  });

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    url: `https://mail.google.com/mail/u/0/#drafts?compose=${draft.message.id}`,
  };
}

__ = {
  /**
   * Compute the reply to the last Message of a Thread
   * @param {string} threadId - Id of the Thread
   * @returns {Promise<object>} { from, to, cc, subject, inReplyTo, references }
   */
  async readReply(threadId) {
    const aliases = __.getAliases();
    const thread = await __.getThread(threadId, {
      query: { format: 'full' },
    });
    const last = _.maxBy(thread.messages, (message) =>
      Number(message.internalDate),
    );
    return buildReply(
      {
        from: header(last, 'From'),
        replyTo: header(last, 'Reply-To'),
        to: header(last, 'To'),
        cc: header(last, 'Cc'),
        subject: header(last, 'Subject'),
        rfcMessageId: header(last, 'Message-ID'),
        references: header(last, 'References'),
      },
      aliases,
    );
  },
  buildRaw,
  callApi,
  getAliases,
  getThread,
  read,
  renderBody,
};
