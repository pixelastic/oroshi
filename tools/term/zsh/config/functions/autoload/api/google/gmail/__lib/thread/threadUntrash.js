import { callThread } from './callThread.js';
import { requireThreadId } from './requireThreadId.js';

export let __;

/**
 * Restore a Thread from the trash
 * @param {object} options - Untrash options
 * @param {string} options.threadId - Id of the Thread, as printed by the other thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @returns {Promise<object>} The restored Thread, as { threadId }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function threadUntrash(options) {
  const { threadId } = options;

  requireThreadId(threadId);
  await __.callThread({ threadId, action: 'untrash' });

  return { threadId };
}

__ = {
  callThread,
};
