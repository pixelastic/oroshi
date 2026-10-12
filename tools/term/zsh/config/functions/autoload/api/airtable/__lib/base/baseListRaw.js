import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { callApi } from '../callApi.js';
import { formatBase } from './formatBase.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * List the Bases the token can access as raw lines, one per Base. A line
 * holds the Base ID, then the Base name
 * @param {object} [options] - List options
 * @param {number} [options.limit] - Maximum number of Bases
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function baseListRaw(options = {}) {
  const { limit = DEFAULT_LIMIT } = options;

  const response = await __.callApi('meta/bases');

  return _.chain(response.bases)
    .take(limit)
    .map(__.formatBase)
    .map((base) => __.toLine(base))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Base into a raw line
   * @param {object} base - Base, as formatted by formatBase
   * @returns {string} The Base ID and name, separated by ▮
   */
  toLine(base) {
    return _.chain([base.id, base.name])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  callApi,
  formatBase,
};
