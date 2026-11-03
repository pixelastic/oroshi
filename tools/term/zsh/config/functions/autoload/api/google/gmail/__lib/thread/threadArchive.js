import { modifyLabels } from './modifyLabels.js';
import { requireThreadId } from './requireThreadId.js';

export let __;

/**
 * Remove a Thread from the Inbox
 * @param {object} options - Archive options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The archived Thread, as { threadId }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function threadArchive(options) {
  const { threadId } = options;

  requireThreadId(threadId);
  await __.modifyLabels({ threadId, remove: ['INBOX'] });

  return { threadId };
}

__ = {
  modifyLabels,
};
