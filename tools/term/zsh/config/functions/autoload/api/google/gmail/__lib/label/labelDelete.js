import { callApi } from '../callApi.js';
import { resolveLabel } from './resolveLabel.js';

export let __;

/**
 * Delete a user label. Gmail removes the label from every Thread and keeps the Threads. The action is irreversible
 * @param {object} options - Delete options
 * @param {string} options.name - Name of the label. Throws GMAIL_LABEL_NOT_FOUND if no user label has this name, system labels included
 * @returns {Promise<object>} The id of the deleted label, as { labelId }
 */
export async function labelDelete(options) {
  const { name } = options;

  const labelId = await __.resolveLabel(name);
  await __.callApi(`labels/${labelId}`, { method: 'DELETE' });

  return { labelId };
}

__ = {
  callApi,
  resolveLabel,
};
