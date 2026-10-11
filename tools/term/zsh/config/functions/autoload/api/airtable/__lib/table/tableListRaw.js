import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { airtableRawColumn } from '../rawColumn.js';
import { airtableSeparators } from '../separators.js';
import { formatTable } from './formatTable.js';

export let __;

const DEFAULT_LIMIT = 25;

/**
 * List the Tables of a Base as raw lines, one per Table. A line holds the
 * Table ID, then the Table name
 * @param {object} options - List options
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {number} [options.limit] - Maximum number of Tables
 * @returns {Promise<string>} Raw lines, joined with a newline
 */
export async function tableListRaw(options) {
  const { baseId, limit = DEFAULT_LIMIT } = options;

  // Without it the endpoint would be meta/bases/undefined/tables
  if (!baseId) {
    throw firostError('AIRTABLE_BASE_ID_MISSING', 'Pass --baseId');
  }

  const response = await __.callApi(`meta/bases/${baseId}/tables`);

  const separators = await __.airtableSeparators();
  return _.chain(response.tables)
    .take(limit)
    .map(__.formatTable)
    .map((table) => __.toLine(table, separators))
    .join('\n')
    .value();
}

__ = {
  /**
   * Turn one Table into a raw line
   * @param {object} table - Table, as formatted by formatTable
   * @param {object} separators - { field, list }
   * @returns {string} The Table ID and name, separated by the field separator
   */
  toLine(table, separators) {
    return _.chain([table.id, table.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value();
  },
  airtableSeparators,
  callApi,
  formatTable,
};
