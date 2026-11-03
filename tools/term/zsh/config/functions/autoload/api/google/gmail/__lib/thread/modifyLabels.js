import { callThread } from './callThread.js';

export let __;

/**
 * Add and remove labels on every Message of a Thread
 * @param {object} options - Modification options
 * @param {string} options.threadId - Id of the Thread
 * @param {string[]} [options.add] - Ids of the labels to add
 * @param {string[]} [options.remove] - Ids of the labels to remove
 * @returns {Promise<object>} The Thread, as returned by the Gmail API. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function modifyLabels(options) {
  const { threadId, add, remove } = options;

  return await __.callThread({
    threadId,
    action: 'modify',
    body: { addLabelIds: add, removeLabelIds: remove },
  });
}

__ = {
  callThread,
};
