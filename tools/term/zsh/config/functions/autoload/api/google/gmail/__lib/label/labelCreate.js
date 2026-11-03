import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { getLabels } from './getLabels.js';

export let __;

/**
 * Create a user label
 * @param {object} options - Creation options
 * @param {string} options.name - Name of the label. Throws GMAIL_LABEL_NAME_MISSING if empty, GMAIL_LABEL_NAME_SYSTEM if it is the name of a system label, and GMAIL_LABEL_EXISTS if a label has this name
 * @returns {Promise<object>} The label, as { labelId, name }
 */
export async function labelCreate(options) {
  const { name } = options;

  if (!name) {
    throw firostError('GMAIL_LABEL_NAME_MISSING', 'Pass the name of a label');
  }

  // Gmail compares the names without case
  const sameName = _.filter(
    await __.getLabels(),
    (label) => _.toLower(label.name) === _.toLower(name),
  );
  if (_.some(sameName, { type: 'system' })) {
    throw firostError(
      'GMAIL_LABEL_NAME_SYSTEM',
      `${name} is the name of a system label`,
    );
  }
  if (!_.isEmpty(sameName)) {
    throw firostError('GMAIL_LABEL_EXISTS', `Label ${name} already exists`);
  }

  const response = await __.callApi('labels', {
    method: 'POST',
    body: { name },
  });

  return { labelId: response.id, name: response.name };
}

__ = {
  callApi,
  getLabels,
};
