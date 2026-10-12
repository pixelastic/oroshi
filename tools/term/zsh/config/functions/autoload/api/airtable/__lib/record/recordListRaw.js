import { _ } from 'golgoth';
import { rawColumn } from '@oroshi/api-shared/rawColumn.js';
import { recordSearch } from './recordSearch.js';

export let __;

/**
 * List the Records of a Table as raw lines, one per Record. A line holds the
 * Record ID, then its Fields as JSON
 * @param {object} options - Same options as search
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function recordListRaw(options) {
  // Ask search for the Records, with the flags we received
  const records = await __.recordSearch(options);

  return _.chain(records)
    .map((record) => __.toLine(record))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Record into a raw line
   * @param {object} record - Record, as returned by search
   * @returns {string} The Record ID and its Fields as JSON, separated by ▮
   */
  toLine(record) {
    return _.chain([record.id, record.fields])
      .map((value) => rawColumn(value))
      .join('▮')
      .value();
  },
  recordSearch,
};
