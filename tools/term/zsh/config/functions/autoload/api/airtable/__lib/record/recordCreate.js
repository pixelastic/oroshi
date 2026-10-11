import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatRecord } from './formatRecord.js';
import { recordParseContent } from './recordParseContent.js';

export let __;

/**
 * Create one Record in a Table
 * @param {object} options - Content of the Record, and its anchors
 * @param {string|object} [options.content] - Fields as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of Fields. Wins over content
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @returns {Promise<object>} The new Record, formatted
 */
export async function recordCreate(options) {
  const { content, dataFile, baseId, tableId } = options;

  // Without baseId and tableId, the endpoint would contain undefined
  if (!baseId) {
    throw firostError('AIRTABLE_BASE_ID_MISSING', 'Pass --baseId');
  }
  if (!tableId) {
    throw firostError('AIRTABLE_TABLE_ID_MISSING', 'Pass --tableId');
  }

  const fields = await __.recordParseContent({ content, dataFile });

  const response = await __.callApi(
    `${baseId}/${encodeURIComponent(tableId)}`,
    {
      method: 'POST',
      body: { fields },
    },
  );
  return __.formatRecord(response);
}

__ = {
  callApi,
  formatRecord,
  recordParseContent,
};
