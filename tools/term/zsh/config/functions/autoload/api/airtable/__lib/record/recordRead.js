import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatRecord } from './formatRecord.js';

export let __;

/**
 * Read one Record of a Table
 * @param {object} options - Id of the Record, and its anchors
 * @param {string} options.recordId - Record ID. Throws AIRTABLE_RECORD_ID_MISSING if empty
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @returns {Promise<object>} The Record, formatted
 */
export async function recordRead(options) {
  const { recordId, baseId, tableId } = options;

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

  const response = await __.callApi(
    `${baseId}/${encodeURIComponent(tableId)}/${recordId}`,
  );
  return __.formatRecord(response);
}

__ = {
  callApi,
  formatRecord,
};
