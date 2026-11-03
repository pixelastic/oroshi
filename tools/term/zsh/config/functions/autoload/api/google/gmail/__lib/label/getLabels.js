import { _ } from 'golgoth';
import { callApi } from '../callApi.js';

export let __;

/**
 * Fetch every label of the Account, system labels included. labels.list has no
 * filter and no pagination
 * @returns {Promise<object[]>} The labels, as { labelId, name, type, backgroundColor, textColor }. The colors are undefined for a label without color
 */
export async function getLabels() {
  const response = await __.callApi('labels');

  return _.chain(response)
    .get('labels', [])
    .map((label) => ({
      labelId: label.id,
      name: label.name,
      type: label.type,
      backgroundColor: _.get(label, 'color.backgroundColor'),
      textColor: _.get(label, 'color.textColor'),
    }))
    .value();
}

__ = {
  callApi,
};
