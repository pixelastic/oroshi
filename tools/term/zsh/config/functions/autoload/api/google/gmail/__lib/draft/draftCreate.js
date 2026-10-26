import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { buildRaw } from './buildRaw.js';

export let __;

/**
 * Create a plain-text draft in Gmail
 * @param {object} options - Draft options
 * @param {string} options.to - Recipient. Throws GMAIL_TO_MISSING if empty
 * @param {string} options.subject - Subject. Throws GMAIL_SUBJECT_MISSING if empty
 * @param {string} options.body - Body, sent as is as text/plain. Throws GMAIL_BODY_MISSING if empty
 * @returns {Promise<object>} { draftId, threadId, url }, the url opening the draft in Gmail
 */
export async function draftCreate(options) {
  const { to, subject, body } = options;

  if (!to) {
    throw firostError('GMAIL_TO_MISSING', 'Pass the recipient with --to');
  }
  if (!subject) {
    throw firostError('GMAIL_SUBJECT_MISSING', 'Pass the --subject');
  }
  if (!body) {
    throw firostError('GMAIL_BODY_MISSING', 'Pass the --body');
  }

  const raw = await __.buildRaw({ to, subject, body });
  const draft = await __.callApi('drafts', {
    method: 'POST',
    body: { message: { raw } },
  });

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    url: `https://mail.google.com/mail/u/0/#drafts?compose=${draft.message.id}`,
  };
}

__ = {
  buildRaw,
  callApi,
};
