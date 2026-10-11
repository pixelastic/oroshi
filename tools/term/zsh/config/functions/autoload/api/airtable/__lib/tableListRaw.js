import { _ } from 'golgoth';
import { callApi } from './callApi.js';
import { airtableRawColumn } from './rawColumn.js';
import { airtableSeparators } from './separators.js';

export let __;

/**
 * List the Tables of a Base as raw lines, one per Table. A line holds the
 * Table ID, then the Table name
 * @param {object} options - List options
 * @param {string} options.base - Base ID
 * @returns {Promise<string[]>} Raw lines
 */
export async function airtableTableListRaw(options) {
  const { base } = options;

  const response = await __.callApi(`meta/bases/${base}/tables`);

  const separators = await airtableSeparators();
  return _.map(response.tables, (table) =>
    _.chain([table.id, table.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value(),
  );
}

__ = { callApi };
