import { _ } from 'golgoth';
import { firostError } from 'firost';
import { getLabels } from './getLabels.js';

export let __;

/**
 * Find the id of a user label from its name. The Gmail API takes ids only, and
 * no endpoint turns a name into an id
 * @param {string} name - Name of the label. Gmail compares the names without case
 * @returns {Promise<string>} The id of the label. Throws GMAIL_LABEL_NOT_FOUND if no user label has this name, system labels included
 */
export async function resolveLabel(name) {
  const labels = await __.getLabels();
  const label = _.find(
    labels,
    (item) => item.type === 'user' && _.toLower(item.name) === _.toLower(name),
  );

  if (!label) {
    throw firostError(
      'GMAIL_LABEL_NOT_FOUND',
      `Label ${name} not found. Create it with gmail-label-create`,
    );
  }

  return label.labelId;
}

__ = {
  getLabels,
};
