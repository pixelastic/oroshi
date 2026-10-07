import { _ } from 'golgoth';
import { airtableApi } from './api.js';
import { airtableRawColumn } from './rawColumn.js';
import { airtableSeparators } from './separators.js';

/**
 * List the Tables of a Base as raw lines, one per Table. A line holds the
 * Table ID, then the Table name
 * @param {object} options - List options
 * @param {string} options.base - Base ID
 * @returns {Promise<string[]>} Raw lines
 */
export async function airtableTableListRaw(options) {
  const { base } = options;

  const response = await airtableApi({
    mode: 'read',
    method: 'GET',
    host: 'schema',
    base,
    path: 'tables',
  });

  const separators = await airtableSeparators();
  return _.map(response.tables, (table) =>
    _.chain([table.id, table.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value(),
  );
}
