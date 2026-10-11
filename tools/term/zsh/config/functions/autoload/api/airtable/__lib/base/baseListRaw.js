import { _ } from 'golgoth';
import { callApi } from '../callApi.js';
import { airtableRawColumn } from '../rawColumn.js';
import { airtableSeparators } from '../separators.js';
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

  const separators = await __.airtableSeparators();
  return _.chain(response.bases)
    .take(limit)
    .map(__.formatBase)
    .map((base) => __.toLine(base, separators))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Base into a raw line
   * @param {object} base - Base, as formatted by formatBase
   * @param {object} separators - { field, list }
   * @returns {string} The Base ID and name, separated by the field separator
   */
  toLine(base, separators) {
    return _.chain([base.id, base.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value();
  },
  airtableSeparators,
  callApi,
  formatBase,
};
