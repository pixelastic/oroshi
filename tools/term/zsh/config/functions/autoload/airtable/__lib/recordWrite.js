import { airtableApi } from './api.js';

/**
 * Create a Record, or update the given one, and return its ID. An update leaves
 * the Fields that are not given untouched
 * @param {object} options - Write options
 * @param {string} options.base - Base ID
 * @param {string} options.table - Table name
 * @param {string} [options.record] - Record ID to update. A new Record is created without it
 * @param {object} options.fields - Regular Fields to set, never Attachments
 * @returns {Promise<string>} The ID of the Record
 */
export async function airtableRecordWrite(options) {
  const { base, table, record, fields } = options;

  const response = await airtableApi({
    mode: 'write',
    method: record ? 'PATCH' : 'POST',
    base,
    path: record ? [table, record] : table,
    body: { fields },
  });

  return response.id;
}
