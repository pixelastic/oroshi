import { _ } from 'golgoth';
import { airtableApi } from './api.js';
import { airtableRawColumn } from './rawColumn.js';
import { airtableSeparators } from './separators.js';

export let __;

const MAX_PAGE_SIZE = 100;

/**
 * List the Records of a Table as raw lines, one per Record, with a single API
 * call. A line holds the Record ID, then the requested Fields in the order
 * given. The values of a multi-value Field use the list separator
 * @param {object} options - List options
 * @param {string} options.base - Base ID
 * @param {string} options.table - Table name
 * @param {string[]} [options.fields] - Fields to print, none by default
 * @param {number} [options.limit] - Maximum number of Records, capped at 100
 * @param {string} [options.sort] - Field to sort on, prefixed with - to sort descending
 * @returns {Promise<string[]>} Raw lines
 */
export async function airtableRecordListRaw(options) {
  const { base, table, fields = [], limit, sort } = options;

  const response = await airtableApi({
    mode: 'read',
    method: 'GET',
    base,
    path: table,
    query: {
      pageSize: limit && Math.min(limit, MAX_PAGE_SIZE),
      sort: sort && [__.sortOption(sort)],
      fields,
    },
  });

  const separators = await airtableSeparators();
  return _.map(response.records, (record) =>
    [
      record.id,
      ..._.map(fields, (field) =>
        airtableRawColumn(record.fields[field], separators),
      ),
    ].join(separators.field),
  );
}

__ = {
  /**
   * Convert a sort argument into an Airtable sort option. A leading dash sorts
   * descending
   * @param {string} sort - Field name, optionally prefixed with -
   * @returns {object} Sort option { field, direction }
   */
  sortOption(sort) {
    return {
      field: _.trimStart(sort, '-'),
      direction: _.startsWith(sort, '-') ? 'desc' : 'asc',
    };
  },
};
