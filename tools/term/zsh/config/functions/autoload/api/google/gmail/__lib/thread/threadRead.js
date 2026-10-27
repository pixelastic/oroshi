import { _ } from 'golgoth';
import { firostError } from 'firost';
import { formatThread } from './formatThread.js';
import { getDraftIds } from './getDraftIds.js';
import { getThread } from './getThread.js';

export let __;

/**
 * Read a Thread as a whole
 * @param {object} options - Read options
 * @param {string} options.threadId - Id of the Thread. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The Thread as { threadId, subject, unread, messages }, its Messages formatted, oldest first. Each Message has isDraft, and a Draft Message has its draftId
 */
export async function threadRead(options) {
  const { threadId } = options;

  if (!threadId) {
    throw firostError('GMAIL_THREAD_ID_MISSING', 'Pass the id of a Thread');
  }

  const response = await __.getThread(threadId, {
    query: { format: 'full' },
  });
  const thread = __.formatThread(response);
  const draftMessageIds = _.chain(response.messages)
    .filter((message) => _.includes(message.labelIds, 'DRAFT'))
    .map('id')
    .value();
  // The list of all the Drafts is only worth a call when the Thread holds one
  const draftIds = _.isEmpty(draftMessageIds) ? {} : await __.getDraftIds();

  return {
    ..._.pick(thread, ['threadId', 'subject', 'unread']),
    messages: _.map(thread.messages, (message) => {
      const isDraft = _.includes(draftMessageIds, message.messageId);
      return {
        ...message,
        isDraft,
        ...(isDraft && { draftId: draftIds[message.messageId] }),
      };
    }),
  };
}

__ = {
  formatThread,
  getDraftIds,
  getThread,
};
