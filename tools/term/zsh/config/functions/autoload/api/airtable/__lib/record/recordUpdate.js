import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatRecord } from './formatRecord.js';
import { recordParseContent } from './recordParseContent.js';

export let __;

/**
 * Update some Fields of one Record. The other Fields keep their value
 * @param {object} options - Id of the Record, its new content, and its anchors
 * @param {string} options.recordId - Record ID. Throws AIRTABLE_RECORD_ID_MISSING if empty
 * @param {string|object} [options.content] - Fields to change, as a JSON string, or the object itself
 * @param {string} [options.dataFile] - Path to a JSON file of Fields. Wins over content
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @returns {Promise<object>} The updated Record, formatted
 */
export async function recordUpdate(options) {
  const { recordId, content, dataFile, baseId, tableId } = options;

  // Without recordId, baseId and tableId, the endpoint would contain undefined
  if (!recordId) {
    throw firostError('AIRTABLE_RECORD_ID_MISSING', 'Pass the Record ID');
  }
  if (!baseId) {
    throw firostError('AIRTABLE_BASE_ID_MISSING', 'Pass --baseId');
  }
  if (!tableId) {
    throw firostError('AIRTABLE_TABLE_ID_MISSING', 'Pass --tableId');
  }

  const fields = await __.recordParseContent({ content, dataFile });

  // PATCH leaves the Fields that are not given untouched
  const response = await __.callApi(
    `${baseId}/${encodeURIComponent(tableId)}/${recordId}`,
    { method: 'PATCH', body: { fields } },
  );
  return __.formatRecord(response);
}

__ = {
  callApi,
  formatRecord,
  recordParseContent,
};
