import { modifyLabels } from '../thread/modifyLabels.js';
import { requireThreadId } from '../thread/requireThreadId.js';
import { resolveLabel } from './resolveLabel.js';

export let __;

/**
 * Attach a user label to a Thread. Attaching a label that the Thread carries already changes nothing
 * @param {object} options - Attach options
 * @param {string} options.threadId - Id of the Thread, as printed by the thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @param {string} options.name - Name of the label. Throws GMAIL_LABEL_NOT_FOUND if no user label has this name
 * @returns {Promise<object>} The Thread and the label, as { threadId, name }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function labelAttach(options) {
  const { threadId, name } = options;

  __.requireThreadId(threadId);

  const labelId = await __.resolveLabel(name);
  await __.modifyLabels({ threadId, add: [labelId] });

  return { threadId, name };
}

__ = {
  modifyLabels,
  requireThreadId,
  resolveLabel,
};
