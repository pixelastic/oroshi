import { _ } from 'golgoth';
import { airtableRawColumn } from '../rawColumn.js';
import { airtableSeparators } from '../separators.js';
import { recordSearch } from './recordSearch.js';

export let __;

/**
 * List the Records of a Table as raw lines, one per Record. A line holds the
 * Record ID, then its Fields as JSON
 * @param {object} options - Same options as search, without the formula
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function recordListRaw(options) {
  // An empty formula matches every Record
  const records = await __.recordSearch({ ...options, query: '' });

  const separators = await __.airtableSeparators();
  return _.chain(records)
    .map((record) => __.toLine(record, separators))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Record into a raw line
   * @param {object} record - Record, as returned by search
   * @param {object} separators - { field, list }
   * @returns {string} The Record ID and its Fields as JSON, separated by the field separator
   */
  toLine(record, separators) {
    return _.chain([record.id, record.fields])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value();
  },
  airtableSeparators,
  recordSearch,
};
