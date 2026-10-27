import { _ } from 'golgoth';
import { firostError } from 'firost';
import { formatMessage } from '../thread/formatMessage.js';
import { getDraft } from './getDraft.js';

export let __;

/**
 * Read one Draft, with its attachments
 * @param {object} options - Read options
 * @param {string} options.draftId - Id of the Draft, as printed by gmail-draft-create and thread-read. Throws GMAIL_DRAFT_ID_MISSING if empty
 * @returns {Promise<object>} The Draft as { draftId, threadId, messageId, from, to, subject, body, attachments }. Throws GMAIL_DRAFT_NOT_FOUND if the Draft does not exist
 */
export async function draftRead(options) {
  const { draftId } = options;

  if (!draftId) {
    throw firostError('GMAIL_DRAFT_ID_MISSING', 'Pass the id of a Draft');
  }

  const draft = await __.getDraft(draftId, 'full');
  const message = formatMessage(draft.message);

  return {
    draftId: draft.id,
    threadId: draft.message.threadId,
    ..._.omit(message, ['date', 'snippet']),
  };
}

__ = {
  getDraft,
};
