import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { getLabels } from './getLabels.js';

export let __;

/**
 * List the user labels as raw lines, one per label
 * @param {object} options - Options of the listing
 * @param {string} [options.query] - Keep the labels whose name contains this text, ignoring case
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function labelListRaw(options) {
  const { query = '' } = options;
  const needle = _.toLower(query);

  const labels = await __.getLabels();

  return _.chain(labels)
    .filter({ type: 'user' })
    .filter((label) => _.chain(label.name).toLower().includes(needle).value())
    .map(__.toLine)
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one label into a raw line
   * @param {object} label - Label, as returned by getLabels
   * @returns {string} The label fields, separated by ▮
   */
  toLine(label) {
    return _.chain([
      label.labelId,
      label.name,
      label.type,
      label.backgroundColor,
      label.textColor,
    ])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },

  getLabels,
};
