import { _ } from 'golgoth';
import { callApi } from './callApi.js';
import { airtableRawColumn } from './rawColumn.js';
import { airtableSeparators } from './separators.js';

export let __;

/**
 * List the Bases the token can access as raw lines, one per Base. A line
 * holds the Base ID, then the Base name
 * @returns {Promise<string[]>} Raw lines
 */
export async function airtableBaseListRaw() {
  const response = await __.callApi('meta/bases');

  const separators = await airtableSeparators();
  return _.map(response.bases, (base) =>
    _.chain([base.id, base.name])
      .map((value) => airtableRawColumn(value, separators))
      .join(separators.field)
      .value(),
  );
}

__ = { callApi };
