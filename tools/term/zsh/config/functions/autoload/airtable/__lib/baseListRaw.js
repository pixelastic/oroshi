import { _ } from 'golgoth';
import { airtableApi } from './api.js';
import { airtableRawColumn } from './rawColumn.js';
import { airtableSeparators } from './separators.js';

/**
 * List the Bases the Read token can access as raw lines, one per Base. A line
 * holds the Base ID, then the Base name
 * @returns {Promise<string[]>} Raw lines
 */
export async function airtableBaseListRaw() {
  const response = await airtableApi({
    mode: 'read',
    method: 'GET',
    host: 'schema',
  });

  const separators = await airtableSeparators();
  return _.map(response.bases, (base) =>
    _.chain([base.id, base.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value(),
  );
}
