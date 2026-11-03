import { callThread } from './callThread.js';
import { requireThreadId } from './requireThreadId.js';

export let __;

/**
 * Move a Thread to the trash. Gmail purges it after 30 days
 * @param {object} options - Trash options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The trashed Thread, as { threadId }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function threadTrash(options) {
  const { threadId } = options;

  requireThreadId(threadId);
  await __.callThread({ threadId, action: 'trash' });

  return { threadId };
}

__ = {
  callThread,
};
