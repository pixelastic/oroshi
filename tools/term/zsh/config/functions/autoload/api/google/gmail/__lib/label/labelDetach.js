import { firostError } from 'firost';
import { modifyLabels } from '../thread/modifyLabels.js';
import { resolveLabel } from './resolveLabel.js';

export let __;

/**
 * Detach a user label from a Thread. Detaching a label that the Thread does not carry changes nothing
 * @param {object} options - Detach options
 * @param {string} options.threadId - Id of the Thread, as printed by the thread commands. Throws GMAIL_THREAD_ID_MISSING if empty
 * @param {string} options.name - Name of the label. Throws GMAIL_LABEL_NOT_FOUND if no user label has this name
 * @returns {Promise<object>} The Thread and the label, as { threadId, name }. Throws GMAIL_THREAD_NOT_FOUND if the Thread does not exist
 */
export async function labelDetach(options) {
  const { threadId, name } = options;

  if (!threadId) {
    throw firostError('GMAIL_THREAD_ID_MISSING', 'Pass the id of a Thread');
  }

  const labelId = await __.resolveLabel(name);
  await __.modifyLabels({ threadId, remove: [labelId] });

  return { threadId, name };
}

__ = {
  modifyLabels,
  resolveLabel,
};
