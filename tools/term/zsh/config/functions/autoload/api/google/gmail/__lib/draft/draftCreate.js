import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { header } from '../header.js';
import { buildRaw } from './buildRaw.js';
import { buildReply } from './buildReply.js';
import { getAliases } from './getAliases.js';

export let __;

const METADATA_QUERY = `format=metadata&${[
  'From',
  'Reply-To',
  'To',
  'Cc',
  'Subject',
  'Message-ID',
  'References',
]
  .map((name) => `metadataHeaders=${name}`)
  .join('&')}`;

/**
 * Create a plain-text draft in Gmail
 * @param {object} options - Draft options
 * @param {string} [options.account] - Name of the account, to read its aliases
 * @param {string} [options.messageId] - Id of the Message to reply to. The reply goes to its last Mail, in its thread
 * @param {string} [options.to] - Recipient. Overrides the reply. Throws GMAIL_TO_MISSING if empty without messageId
 * @param {string} [options.subject] - Subject. Overrides the reply. Throws GMAIL_SUBJECT_MISSING if empty without messageId
 * @param {string} options.body - Body, sent as is as text/plain. Throws GMAIL_BODY_MISSING if empty
 * @returns {Promise<object>} { draftId, threadId, url }, the url opening the draft in Gmail
 */
export async function draftCreate(options) {
  const { messageId, body, account } = options;

  const reply = messageId ? await __.readReply(messageId, account) : {};
  const to = options.to || reply.to;
  const subject = options.subject || reply.subject;
  const { from, cc, inReplyTo, references } = reply;

  if (!to) {
    throw firostError('GMAIL_TO_MISSING', 'Pass the recipient with --to');
  }
  if (!subject) {
    throw firostError('GMAIL_SUBJECT_MISSING', 'Pass the --subject');
  }
  if (!body) {
    throw firostError('GMAIL_BODY_MISSING', 'Pass the --body');
  }

  const raw = await __.buildRaw({
    from,
    to,
    cc,
    subject,
    body,
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
   * @returns {Promise<object>} { from, to, cc, subject, inReplyTo, references }
   */
  async readReply(messageId, account) {
    const aliases = __.getAliases(account);
    // The query string is part of the path, because callApi cannot repeat a
    // parameter
    const thread = await __.callApi(`threads/${messageId}?${METADATA_QUERY}`);
    const last = _.maxBy(thread.messages, (mail) => Number(mail.internalDate));
    return buildReply(
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
  },
  buildRaw,
  callApi,
  getAliases,
};
